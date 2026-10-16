//
//  TransactionSplitData.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionSplitData: DataProtocol {
    var id      : DataId = .void
    var transId : DataId = .void
    var categId : DataId = .void
    var amount  : Double = 0.0
    var notes   : String = ""
}

extension TransactionSplitData {
    static let dataName = ("Transaction Split", "Transaction Splits")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: TransactionSplitData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension TransactionSplitData {
    static let sampleData: [TransactionSplitData] = [
        // for transId = 4
        TransactionSplitData(id: 1, transId: 5, categId: 12, amount: 34.20, notes: "Brunch"),
        TransactionSplitData(id: 2, transId: 5, categId: 10, amount: 24.00, notes: "Train tickets")
    ]
}
