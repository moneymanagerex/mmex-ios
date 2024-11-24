//
//  StockValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension StockData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }
        if symbol.isEmpty {
            return "Symbol is empty"
        }

        guard !accountId.isVoid else {
            return "No account is selected"
        }
        guard let accountData = vm.accountList.data.readyValue else {
            return "* accountData is not loaded"
        }
        if accountData[accountId] == nil {
            return "* Unknown account #\(accountId.value)"
        }

        typealias S = ViewModel.S
        guard let s = S(vm) else {
            return "* Database is not available"
        }

        // DB schema does not enforce unique name or symbol.
        // E.g., the same stock may have been purchased more than once.

        if id.isVoid {
            guard s.insert(&self) else {
                return "* Cannot create new stock"
            }
        } else {
            guard s.update(self) else {
                return "* Cannot update stock #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let stockUsed = vm.stockList.used.readyValue else {
            return "* stockUsed is not loaded"
        }
        if stockUsed.contains(id) {
            return "* Stock #\(id.value) is used"
        }

        typealias S = ViewModel.S
        typealias D = ViewModel.D
        guard let s = S(vm), let d = D(vm) else {
            return "* Database is not available"
        }

        // Do not cleanup SH (Stock History), even if this is the last item for a symbol.
        // Offer a different interface to manipulate Stock History.

        guard let stockAtt = vm.stockList.att.readyValue else {
            return "* stockAtt is not loaded"
        }
        if stockAtt[id] != nil {
            guard d.delete(refType: .stock, refId: id) else {
                return "* Cannot delete attachments for stock #\(id.value)"
            }
        }

        guard s.delete(self) else {
            return "* Cannot delete stock #\(id.value)"
        }

        return nil
    }
}
