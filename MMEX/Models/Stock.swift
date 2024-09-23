//
//  Stock.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct StockData: ExportableEntity {
    var id            : Int64
    var accountId     : Int64
    var name          : String
    var symbol        : String
    var numShares     : Double
    var purchaseDate  : String
    var purchasePrice : Double
    var currentPrice  : Double
    var value         : Double
    var commisison    : Double
    var notes         : String

    init(
        id            : Int64   = 0,
        accountId     : Int64   = 0,
        name          : String  = "",
        symbol        : String  = "",
        numShares     : Double  = 0.0,
        purchaseDate  : String  = "",
        purchasePrice : Double  = 0.0,
        currentPrice  : Double  = 0.0,
        value         : Double  = 0.0,
        commisison    : Double  = 0.0,
        notes         : String  = ""
    ) {
        self.id            = id
        self.accountId     = accountId
        self.name          = name
        self.symbol        = symbol
        self.numShares     = numShares
        self.purchaseDate  = purchaseDate
        self.purchasePrice = purchasePrice
        self.currentPrice  = currentPrice
        self.value         = value
        self.commisison    = commisison
        self.notes         = notes
    }
}

extension StockData: DataProtocol {
    static let modelName = "Stock"

    func shortDesc() -> String {
        "\(self.name), \(self.id)"
    }
}

struct StockFull: FullProtocol {
    var data: StockData
    var account: AccountFull?
}

extension StockData {
    static let sampleData: [StockData] = [
        StockData(
            id: 1, accountId: 3, name: "Apple", symbol: "AAPL",
            numShares: 1, purchaseDate: "2022-01-14",
            purchasePrice: 150.60, currentPrice: 200.00, 
            notes: "I should buy more"
        ),
    ]
}
