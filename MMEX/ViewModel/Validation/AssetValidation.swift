//
//  AssetValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension AssetData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        guard !currencyId.isVoid else {
            return "No currency is selected"
        }
        guard let currencyName = vm.currencyList.name.readyValue else {
            return "* currencyName is not loaded"
        }
        if currencyName[currencyId] == nil {
            return "* Unknown currency #\(currencyId.value)"
        }

        typealias E = ViewModel.E
        guard let e = E(vm.db) else {
            return "* Database is not available"
        }

        // DB schema does not enforce unique name.
        // E.g., two Assets may have the same name and different type.

        if id.isVoid {
            guard e.insert(&self) else {
                return "* Cannot create new asset"
            }
        } else {
            guard e.update(self) else {
                return "* Cannot update asset #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let assetUsed = vm.assetList.used.readyValue else {
            return "* assetUsed is not loaded"
        }
        if assetUsed.contains(id) {
            return "* Asset #\(id.value) is used"
        }

        typealias E = ViewModel.E
        typealias D = ViewModel.D
        guard let e = E(vm.db), let d = D(vm.db) else {
            return "* Database is not available"
        }

        guard let assetAtt = vm.assetList.attachment.readyValue else {
            return "* assetAtt is not loaded"
        }
        if assetAtt[id] != nil {
            guard d.delete(refType: .asset, refId: id) else {
                return "* Cannot delete attachments for asset #\(id.value)"
            }
        }

        guard e.delete(self) else {
            return "* Cannot delete asset #\(id.value)"
        }

        return nil
    }
}
