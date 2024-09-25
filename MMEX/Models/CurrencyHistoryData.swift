//
//  CurrencyHistory.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct CurrencyHistoryData: ExportableEntity {
    var id           : Int64       = 0
    var currencyId   : Int64       = 0
    var date         : String      = ""
    var baseConvRate : Double      = 0.0
    var updateType   : UpdateType? = nil
}

extension CurrencyHistoryData: DataProtocol {
    static let dataName = "CurrencyHistory"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension CurrencyHistoryData {
    static let sampleData: [CurrencyHistoryData] = [
    ]
}
