//
//  StockRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct StockRepository: RepositoryProtocol {
    typealias RepositoryData = StockData

    let db: Connection

    static let repositoryName = "STOCK_V1"
    static let table = SQLite.Table(repositoryName)

    // column        | type    | other
    // --------------+---------+------
    // STOCKID       | INTEGER | PRIMARY KEY
    // HELDAT        | INTEGER |
    // STOCKNAME     | TEXT    | NOT NULL COLLATE NOCASE
    // SYMBOL        | TEXT    |
    // NUMSHARES     | NUMERIC |
    // PURCHASEDATE  | TEXT    | NOT NULL (yyyy-MM-dd)
    // PURCHASEPRICE | NUMERIC | NOT NULL
    // CURRENTPRICE  | NUMERIC | NOT NULL
    // VALUE         | NUMERIC |
    // COMMISSION    | NUMERIC |
    // NOTES         | TEXT    |

    // column expressions
    static let col_id            = SQLite.Expression<Int64>("STOCKID")
    static let col_accountId     = SQLite.Expression<Int64?>("HELDAT")
    static let col_name          = SQLite.Expression<String>("STOCKNAME")
    static let col_symbol        = SQLite.Expression<String?>("SYMBOL")
    static let col_numShares     = SQLite.Expression<Double?>("NUMSHARES")
    static let col_purchaseDate  = SQLite.Expression<String>("PURCHASEDATE")
    static let col_purchasePrice = SQLite.Expression<Double>("PURCHASEPRICE")
    static let col_currentPrice  = SQLite.Expression<Double>("CURRENTPRICE")
    static let col_purchaseValue = SQLite.Expression<Double?>("VALUE")
    static let col_commisison    = SQLite.Expression<Double?>("COMMISSION")
    static let col_notes         = SQLite.Expression<String?>("NOTES")

    // cast NUMERIC to REAL
    static let cast_numShares     = cast(col_numShares)     as SQLite.Expression<Double?>
    static let cast_purchasePrice = cast(col_purchasePrice) as SQLite.Expression<Double>
    static let cast_currentPrice  = cast(col_currentPrice)  as SQLite.Expression<Double>
    static let cast_purchaseValue = cast(col_purchaseValue) as SQLite.Expression<Double?>
    static let cast_commisison    = cast(col_commisison)    as SQLite.Expression<Double?>

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_accountId,
            col_name,
            col_symbol,
            cast_numShares,
            col_purchaseDate,
            cast_purchasePrice,
            cast_currentPrice,
            cast_purchaseValue,
            cast_commisison,
            col_notes
        )
    }

    static func fetchData(_ row: SQLite.Row) -> StockData {
        return StockData(
            id            : DataId(row[col_id]),
            accountId     : DataId(row[col_accountId] ?? 0),
            name          : row[col_name],
            symbol        : row[col_symbol] ?? "",
            numShares     : row[cast_numShares] ?? 0.0,
            purchaseDate  : DateString(row[col_purchaseDate]),
            purchasePrice : row[cast_purchasePrice],
            currentPrice  : row[cast_currentPrice],
            purchaseValue : row[cast_purchaseValue] ?? 0.0,
            commisison    : row[cast_commisison] ?? 0.0,
            notes         : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ data: StockData) -> [SQLite.Setter] {
        return [
            col_accountId     <- Int64(data.accountId),
            col_name          <- data.name,
            col_symbol        <- data.symbol,
            col_numShares     <- data.numShares,
            col_purchaseDate  <- data.purchaseDate.string,
            col_purchasePrice <- data.purchasePrice,
            col_currentPrice  <- data.currentPrice,
            col_purchaseValue <- data.purchaseValue,
            col_commisison    <- data.commisison,
            col_notes         <- data.notes
        ]
    }

    static func filterUsed(_ table: SQLite.Table) -> SQLite.Table {
        typealias TL = TransactionLinkRepository
        let cond = "EXISTS (" + (TL.table.select(1).where(
            TL.table[TL.col_refType] == RefType.stock.rawValue &&
            TL.table[TL.col_refId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }

    static func filterDeps(_ table: SQLite.Table) -> SQLite.Table {
        typealias D = AttachmentRepository
        let cond = "EXISTS (" + (D.table.select(1).where(
            D.table[D.col_refType] == RefType.stock.rawValue &&
            D.table[D.col_refId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }
}
