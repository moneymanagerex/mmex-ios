//
//  StockRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class StockRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }
}

extension StockRepository {
    // table query
    static let table = SQLite.Table("STOCK_V1")

    // column        | type    | other
    // --------------+---------+------
    // STOCKID       | INTEGER | PRIMARY KEY
    // HELDAT        | INTEGER |
    // STOCKNAME     | TEXT    | NOT NULL COLLATE NOCASE
    // SYMBOL        | TEXT    |
    // NUMSHARES     | NUMERIC |
    // PURCHASEDATE  | TEXT    | NOT NULL
    // PURCHASEPRICE | NUMERIC | NOT NULL
    // CURRENTPRICE  | NUMERIC | NOT NULL
    // VALUE         | NUMERIC |
    // COMMISSION    | NUMERIC |
    // NOTES         | TEXT    |

    // table columns
    static let col_id            = SQLite.Expression<Int64>("STOCKID")
    static let col_accountId     = SQLite.Expression<Int64?>("HELDAT")
    static let col_name          = SQLite.Expression<String>("STOCKNAME")
    static let col_symbol        = SQLite.Expression<String?>("SYMBOL")
    static let col_numShares     = SQLite.Expression<Double?>("NUMSHARES")
    static let col_purchaseDate  = SQLite.Expression<String>("PURCHASEDATE")
    static let col_purchasePrice = SQLite.Expression<Double>("PURCHASEPRICE")
    static let col_currentPrice  = SQLite.Expression<Double>("CURRENTPRICE")
    static let col_value         = SQLite.Expression<Double?>("VALUE")
    static let col_commisison    = SQLite.Expression<Double?>("COMMISSION")
    static let col_notes         = SQLite.Expression<String?>("NOTES")

    // cast NUMERIC to REAL
    static let cast_numShares     = cast(col_numShares)     as SQLite.Expression<Double?>
    static let cast_purchasePrice = cast(col_purchasePrice) as SQLite.Expression<Double>
    static let cast_currentPrice  = cast(col_currentPrice)  as SQLite.Expression<Double>
    static let cast_value         = cast(col_value)         as SQLite.Expression<Double?>
    static let cast_commisison    = cast(col_commisison)    as SQLite.Expression<Double?>
}

extension StockRepository {
    // select query
    static let selectQuery = table.select(
        col_id,
        col_accountId,
        col_name,
        col_symbol,
        cast_numShares,
        col_purchaseDate,
        cast_purchasePrice,
        cast_currentPrice,
        cast_value,
        cast_commisison,
        col_notes
    )

    // select result
    static func selectResult(_ row: Row) -> Stock {
        return Stock(
            id            : row[col_id],
            accountId     : row[col_accountId],
            name          : row[col_name],
            symbol        : row[col_symbol],
            numShares     : row[cast_numShares],
            purchaseDate  : row[col_purchaseDate],
            purchasePrice : row[cast_purchasePrice],
            currentPrice  : row[cast_currentPrice],
            value         : row[cast_value],
            commisison    : row[cast_commisison],
            notes         : row[col_notes]
        )
    }

    static func insertSetters(_ stock: Stock) -> [Setter] {
        return [
            col_id            <- stock.id,
            col_accountId     <- stock.accountId,
            col_name          <- stock.name,
            col_symbol        <- stock.symbol,
            col_numShares     <- stock.numShares,
            col_purchaseDate  <- stock.purchaseDate,
            col_purchasePrice <- stock.purchasePrice,
            col_currentPrice  <- stock.currentPrice,
            col_value         <- stock.value,
            col_commisison    <- stock.commisison,
            col_notes         <- stock.notes
        ]
    }

    // insert query
    static func insertQuery(_ stock: Stock) -> SQLite.Insert {
        return table.insert(insertSetters(stock))
    }

    // update query
    static func updateQuery(_ stock: Stock) -> SQLite.Update {
        return table.filter(col_id == stock.id).update(insertSetters(stock))
    }

    // delete query
    static func deleteQuery(_ stock: Stock) -> SQLite.Delete {
        return table.filter(col_id == stock.id).delete()
    }
}

extension StockRepository {
    func loadStocks() -> [Stock] {
        guard let db else { return [] }
        do {
            var stocks: [Stock] = []
            for row in try db.prepare(StockRepository.selectQuery
                .order(StockRepository.col_name)
            ) {
                stocks.append(StockRepository.selectResult(row))
            }
            print("Successfully loaded stocks: \(stocks.count)")
            return stocks
        } catch {
            print("Error loading stocks: \(error)")
            return []
        }
    }

    func addStock(stock: inout Stock) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(StockRepository.insertQuery(stock))
            stock.id = rowid
            print("Successfully added stock: \(stock.name), \(stock.id)")
            return true
        } catch {
            print("Failed to add stock: \(error)")
            return false
        }
    }

    func updateStock(stock: Stock) -> Bool {
        guard let db else { return false }
        do {
            try db.run(StockRepository.updateQuery(stock))
            print("Successfully updated stock: \(stock.name), \(stock.id)")
            return true
        } catch {
            print("Failed to update stock: \(error)")
            return false
        }
    }

    func deleteStock(stock: Stock) -> Bool {
        guard let db else { return false }
        do {
            try db.run(StockRepository.deleteQuery(stock))
            print("Successfully deleted stock: \(stock.name), \(stock.id)")
            return true
        } catch {
            print("Failed to delete stock: \(error)")
            return false
        }
    }
}
