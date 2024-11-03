//
//  TransactionShareData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionShareData: ExportableEntity {
    var id         : DataId = .void
    var transId    : DataId = .void
    var number     : Double = 0.0
    var price      : Double = 0.0
    var commission : Double = 0.0
    var lot        : String = ""
}

extension TransactionShareData: DataProtocol {
    static let dataName = ("Transaction Share", "Transaction Shares")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }
}

extension TransactionShareData {
    static let sampleData: [TransactionShareData] = [
    ]
}
