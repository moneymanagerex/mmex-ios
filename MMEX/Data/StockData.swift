//
//  Stock.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct StockData: ExportableEntity {
    var id            : DataId     = 0
    var accountId     : DataId     = 0
    var name          : String     = ""
    var symbol        : String     = ""
    var numShares     : Double     = 0.0
    var purchaseDate  : DateString = DateString("")
    var purchasePrice : Double     = 0.0
    var currentPrice  : Double     = 0.0
    var purchaseValue : Double     = 0.0
    var commisison    : Double     = 0.0
    var notes         : String     = ""
}

extension StockData: DataProtocol {
    static let dataName = ("Stock", "Stocks")

    func shortDesc() -> String {
        "\(self.name), \(self.id)"
    }
}

extension StockData {
    static let sampleData: [StockData] = [
        StockData(
            id: 1, accountId: 3, name: "Apple", symbol: "AAPL",
            numShares: 2, purchaseDate: DateString("2022-01-14"),
            purchasePrice: 150.60, currentPrice: 200.00, purchaseValue: 301.20,
            notes: "note"
        ),
    ]
}
