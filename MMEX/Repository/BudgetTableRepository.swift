//
//  BudgetTableRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetTableRepository: RepositoryProtocol {
    typealias RepositoryData = BudgetTableData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "BUDGETTABLE_V1"
    static let table = SQLite.Table(repositoryName)

    // column        | type    | other
    // --------------+---------+------
    // BUDGETENTRYID | INTEGER | PRIMARY KEY
    // BUDGETYEARID  | INTEGER |
    // CATEGID       | INTEGER |
    // PERIOD        | TEXT    | NOT NULL (None, Weekly, Bi-Weekly, Monthly, ...)
    // AMOUNT        | NUMERIC | NOT NULL
    // NOTES         | TEXT    |
    // ACTIVE        | INTEGER |

    // column expressions
    static let col_id      = SQLite.Expression<Int64>("BUDGETENTRYID")
    static let col_yearId  = SQLite.Expression<Int64?>("BUDGETYEARID")
    static let col_categId = SQLite.Expression<Int64?>("CATEGID")
    static let col_period  = SQLite.Expression<String>("PERIOD")
    static let col_amount  = SQLite.Expression<Double>("AMOUNT")
    static let col_notes   = SQLite.Expression<String?>("NOTES")
    static let col_active  = SQLite.Expression<Int?>("ACTIVE")

    // cast NUMERIC to REAL
    static let cast_amount = cast(col_amount) as SQLite.Expression<Double>

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_yearId,
            col_categId,
            col_period,
            cast_amount,
            col_notes,
            col_active
        )
    }

    static func fetchData(_ row: SQLite.Row) -> BudgetTableData {
        return BudgetTableData(
            id      : DataId(row[col_id]),
            yearId  : DataId(row[col_yearId] ?? -1),
            categId : DataId(row[col_categId] ?? -1),
            period  : BudgetPeriod(collateNoCase: row[col_period]),
            amount  : row[cast_amount],
            notes   : row[col_notes] ?? "",
            active  : row[col_active] ?? 0 != 0
        )
    }

    static func itemSetters(_ data: BudgetTableData) -> [SQLite.Setter] {
        return [
            col_yearId  <- Int64(data.yearId),
            col_categId <- Int64(data.categId),
            col_period  <- data.period.rawValue,
            col_amount  <- data.amount,
            col_notes   <- data.notes,
            col_active  <- data.active ? 1 : 0
        ]
    }
}

extension BudgetTableRepository {
    // load all budget tables
    func load() -> [BudgetTableData] {
        return select(from: Self.table
            .order(Self.col_id)
        )
    }
}
