//
//  TransactionSplit.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionSplitData: ExportableEntity {
    var id      : Int64  = 0
    var transId : Int64  = 0
    var categId : Int64  = 0
    var amount  : Double = 0.0
    var notes   : String = ""
}

extension TransactionSplitData: DataProtocol {
    static let dataName = "TransactionSplit"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension TransactionSplitData {
    static let sampleData: [TransactionSplitData] = [
    ]
}
