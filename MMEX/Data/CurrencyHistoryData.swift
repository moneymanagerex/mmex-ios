//
//  CurrencyHistoryData.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct CurrencyHistoryData: DataProtocol {
    var id           : DataId      = .void
    var currencyId   : DataId      = .void
    var date         : DateString  = DateString("")
    var baseConvRate : Double      = 0.0
    var updateType   : UpdateType? = nil
    
    // unique(currencyId, date)
}

extension CurrencyHistoryData {
    static let dataName = ("Currency History", "Currency History")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id   = .void
        date = DateString(Date())
    }
}

extension CurrencyHistoryData {
    static let sampleData: [CurrencyHistoryData] = [
    ]
}
