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
        return "* not implemented"
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

        // TODO: cleanup SH (Stock History)

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
