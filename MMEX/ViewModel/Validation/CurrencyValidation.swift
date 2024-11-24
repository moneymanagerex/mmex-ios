//
//  CurrencyValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateCurrency(_ data: inout CurrencyData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }
        if data.symbol.isEmpty {
            return "Symbol is empty"
        }

        guard let u = U(self) else {
            return "* Database is not available"
        }

        guard let dataName = u.selectId(from: U.table.filter(
            U.table[U.col_id] == Int64(data.id) ||
            U.table[U.col_name] == data.name ||
            U.table[U.col_symbol] == data.symbol
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id.isVoid ? 0 : 1) else {
            return "Currency \(data.name) already exists"
        }

        if data.id.isVoid {
            guard u.insert(&data) else {
                return "* Cannot create new currency"
            }
        } else {
            guard u.update(data) else {
                return "* Cannot update currency #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteCurrency(_ data: CurrencyData) -> String? {
        guard let currencyUsed = currencyList.used.readyValue else {
            return "* currencyUsed is not loaded"
        }
        if currencyUsed.contains(data.id) {
            return "* Currency #\(data.id.value) is used"
        }
        // TODO: check base currency

        guard let u = U(self), let uh = UH(self) else {
            return "* Database is not available"
        }

        guard let currencyHistory = currencyList.history.readyValue else {
            return "* currencyHistory is not loaded"
        }
        if currencyHistory[data.id] != nil {
            guard uh.delete(currencyId: data.id) else {
                return "* Cannot delete history for currency #\(data.id.value)"
            }
        }

        guard u.delete(data) else {
            return "* Cannot delete currency #\(data.id.value)"
        }

        return nil
    }
}
