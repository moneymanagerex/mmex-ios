//
//  StockData.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct StockData: DataProtocol {
    var id            : DataId     = .void
    var accountId     : DataId     = .void
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

extension StockData {
    static let dataName = ("Stock", "Stocks")

    func shortDesc() -> String {
        "#\(self.id.value): \(self.name)"
    }

    mutating func copy() {
        id     = .void
        name   = Self.copy(of: name)
        symbol = Self.copy(of: symbol)
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
