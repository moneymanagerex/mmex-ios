//
//  BudgetRepository.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetRepository: RepositoryProtocol {
    typealias RepositoryData = BudgetData

    let db: Connection
    let databaseName: String

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

    static func fetchData(_ row: SQLite.Row) -> BudgetData {
        return BudgetData(
            id         : DataId(row[col_id]),
            periodId   : DataId(row[col_yearId] ?? -1),
            categoryId : DataId(row[col_categId] ?? -1),
            frequency  : BudgetFrequency(collateNoCase: row[col_period]),
            flow       : row[cast_amount],
            notes      : row[col_notes] ?? "",
            active     : row[col_active] ?? 0 != 0
        )
    }

    static func itemSetters(_ data: BudgetData) -> [SQLite.Setter] {
        return [
            col_yearId  <- Int64(data.periodId),
            col_categId <- Int64(data.categoryId),
            col_period  <- data.frequency.rawValue,
            col_amount  <- data.flow,
            col_notes   <- data.notes,
            col_active  <- data.active ? 1 : 0
        ]
    }
}
