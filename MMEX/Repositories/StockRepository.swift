//
//  StockRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class StockRepository: RepositoryProtocol {
    typealias RepositoryItem = Stock

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }
    static let repositoryName = "STOCK_V1"
    static let repositoryTable = SQLite.Table(repositoryName)

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

    // columns
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

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
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
    }

    static func selectResult(_ row: SQLite.Row) -> Stock {
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

    static func itemSetters(_ stock: Stock) -> [SQLite.Setter] {
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
}

extension StockRepository {
    func load() -> [Stock] {
        return select(table: Self.repositoryTable
            .order(Self.col_name)
        )
    }
}
