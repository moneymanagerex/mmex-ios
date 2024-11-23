//
//  BudgetPeriodRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetPeriodRepository: RepositoryProtocol {
    typealias RepositoryData = BudgetPeriodData

    let db: Connection

    static let repositoryName = "BUDGETYEAR_V1"
    static let table = SQLite.Table(repositoryName)

    // column         | type    | other
    // ---------------+---------+------
    // BUDGETYEARID   | INTEGER | PRIMARY KEY
    // BUDGETYEARNAME | TEXT    | NOT NULL UNIQUE

    // column expressions
    static let col_id     = SQLite.Expression<Int64>("BUDGETYEARID")
    static let col_name   = SQLite.Expression<String>("BUDGETYEARNAME")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name
        )
    }

    static func fetchData(_ row: SQLite.Row) -> BudgetPeriodData {
        return BudgetPeriodData(
            id   : DataId(row[col_id]),
            name : row[col_name]
        )
    }

    static func itemSetters(_ data: BudgetPeriodData) -> [SQLite.Setter] {
        return [
            col_name <- data.name
        ]
    }

    static func filterUsed(_ table: SQLite.Table) -> SQLite.Table {
        typealias B = BudgetRepository
        let cond = "EXISTS (" + (B.table.select(1).where(
            B.table[B.col_yearId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }
}
