//
//  StockHistoryRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct StockHistoryRepository: RepositoryProtocol {
    typealias RepositoryData = StockHistoryData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "STOCKHISTORY_V1"
    static let table = SQLite.Table(repositoryName)

    // column  | type    | other
    // --------+---------+------
    // HISTID  | INTEGER | PRIMARY KEY
    // SYMBOL  | TEXT    | NOT NULL
    // DATE    | TEXT    | NOT NULL
    // VALUE   | NUMERIC | NOT NULL
    // UPDTYPE | INTEGER |
    //         |         | UNIQUE(SYMBOL, DATE)

    // column expressions
    static let col_id      = SQLite.Expression<Int64>("HISTID")
    static let col_symbol  = SQLite.Expression<String>("SYMBOL")
    static let col_date    = SQLite.Expression<String>("DATE")
    static let col_value   = SQLite.Expression<Double>("VALUE")
    static let col_updType = SQLite.Expression<Int?>("UPDTYPE")

    // cast NUMERIC to REAL
    static let cast_value = cast(col_value) as SQLite.Expression<Double>

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_symbol,
            col_date,
            cast_value,
            col_updType
        )
    }

    static func selectData(_ row: SQLite.Row) -> StockHistoryData {
        return StockHistoryData(
            id         : row[col_id],
            symbol     : row[col_symbol],
            date       : row[col_date],
            price      : row[cast_value],
            updateType : UpdateType(rawValue: row[col_updType] ?? -1)
        )
    }

    static func itemSetters(_ data: StockHistoryData) -> [SQLite.Setter] {
        return [
            col_symbol  <- data.symbol,
            col_date    <- data.date,
            col_value   <- data.price,
            col_updType <- data.updateType?.rawValue
        ]
    }
}

extension StockHistoryRepository {
    // load all stock history
    func load() -> [StockHistoryData] {
        return select(from: Self.table
            .order(Self.col_symbol, Self.col_date)
        )
    }
}
