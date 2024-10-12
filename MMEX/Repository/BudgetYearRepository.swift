//
//  BudgetYearRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetYearRepository: RepositoryProtocol {
    typealias RepositoryData = BudgetYearData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

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

    static func fetchData(_ row: SQLite.Row) -> BudgetYearData {
        return BudgetYearData(
            id   : DataId(row[col_id]),
            name : row[col_name]
        )
    }

    static func itemSetters(_ data: BudgetYearData) -> [SQLite.Setter] {
        return [
            col_name <- data.name
        ]
    }
}

extension BudgetYearRepository {
    // load all budget years
    func load() -> [BudgetYearData] {
        return select(from: Self.table
            .order(Self.col_name)
        )
    }
}
