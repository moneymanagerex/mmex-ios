//
//  TransactionShareData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionShareData: DataProtocol {
    var id         : DataId = .void
    var transId    : DataId = .void
    var number     : Double = 0.0
    var price      : Double = 0.0
    var commission : Double = 0.0
    var lot        : String = ""
}

extension TransactionShareData {
    static let dataName = ("Transaction Share", "Transaction Shares")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: TransactionShareData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension TransactionShareData {
    static let sampleData: [TransactionShareData] = [
        TransactionShareData(id: 1, transId: 8, number: 2, price: 150.6, commission: 5, lot: ""),
        TransactionShareData(id: 2, transId: 10, number: 10, price: 134.76, commission: 8, lot: ""),
    ]
}
