//
//  CurrencyValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension CurrencyData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }
        if symbol.isEmpty {
            return "Symbol is empty"
        }

        typealias U = ViewModel.U
        guard let u = U(vm.db) else {
            return "* Database is not available"
        }

        guard let dataName = u.selectId(from: U.table.filter(
            U.table[U.col_id] == Int64(id) ||
            U.table[U.col_name] == name ||
            U.table[U.col_symbol] == symbol
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Currency \(name) already exists"
        }

        if id.isVoid {
            guard u.insert(&self) else {
                return "* Cannot create new currency"
            }
        } else {
            guard u.update(self) else {
                return "* Cannot update currency #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let currencyUsed = vm.currencyList.used.readyValue else {
            return "* currencyUsed is not loaded"
        }
        if currencyUsed.contains(id) {
            return "* Currency #\(id.value) is used"
        }
        // TODO: check base currency

        typealias U  = ViewModel.U
        typealias UH = ViewModel.UH
        guard let u = U(vm.db), let uh = UH(vm.db) else {
            return "* Database is not available"
        }

        guard let currencyHistory = vm.currencyList.history.readyValue else {
            return "* currencyHistory is not loaded"
        }
        if currencyHistory[id] != nil {
            guard uh.delete(currencyId: id) else {
                return "* Cannot delete history for currency #\(id.value)"
            }
        }

        guard u.delete(self) else {
            return "* Cannot delete currency #\(id.value)"
        }

        return nil
    }
}
