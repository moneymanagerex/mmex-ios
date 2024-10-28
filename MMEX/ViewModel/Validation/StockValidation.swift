//
//  StockValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateStock(_ data: inout StockData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }
        if data.symbol.isEmpty {
            return "Symbol is empty"
        }

        guard data.accountId > 0 else {
            return "No account is selected"
        }
        guard let accountName = accountList.name.readyValue else {
            return "* accountName is not loaded"
        }
        if accountName[data.accountId] == nil {
            return "* Unknown account #\(data.accountId)"
        }

        guard let s = S(env) else {
            return "* Database is not available"
        }

        // DB schema does not enforce unique name or symbol.
        // E.g., the same stock may have been purchased more than once.

        if data.id <= 0 {
            guard s.insert(&data) else {
                return "* Cannot create new stock"
            }
        } else {
            guard s.update(data) else {
                return "* Cannot update stock #\(data.id)"
            }
        }

        return nil
    }

    func deleteStock(_ data: StockData) -> String? {
        guard let stockUsed = stockList.used.readyValue else {
            return "* stockUsed is not loaded"
        }
        if stockUsed.contains(data.id) {
            return "* Stock #\(data.id) is used"
        }

        guard let s = S(env), let ax = AX(env) else {
            return "* Database is not available"
        }

        // Do not cleanup SH (Stock History), even if this is the last item for a symbol.
        // Offer a different interface to manipulate Stock History.

        guard let stockAtt = stockList.att.readyValue else {
            return "* stockAtt is not loaded"
        }
        if stockAtt[data.id] != nil {
            guard ax.delete(refType: .stock, refId: data.id) else {
                return "* Cannot delete attachments for stock #\(data.id)"
            }
        }

        guard s.delete(data) else {
            return "* Cannot delete stock #\(data.id)"
        }

        return nil
    }
}
