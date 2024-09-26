//
//  TransactionShare.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionShareData: ExportableEntity {
    var id         : Int64  = 0
    var transId    : Int64  = 0
    var number     : Double = 0.0
    var price      : Double = 0.0
    var commission : Double = 0.0
    var lot        : String = ""
}

extension TransactionShareData: DataProtocol {
    static let dataName = "TransactionShare"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension TransactionShareData {
    static let sampleData: [TransactionShareData] = [
    ]
}
