//
//  CategoryRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SQLite

class CategoryRepository: RepositoryProtocol {
    typealias RepositoryData = CategoryData

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "CATEGORY_V1"
    static let table = SQLite.Table(repositoryName)
    static let columns = [ // (column, type, other)
        ("CATEGID",   "INTEGER", "PRIMARY KEY"),
        ("CATEGNAME", "TEXT",    "NOT NULL COLLATE NOCASE"),
        ("ACTIVE",    "INTEGER", ""),
        ("PARENTID",  "INTEGER", ""),
        ("",          "",        "UNIQUE(CATEGNAME, PARENTID)"),
    ]

    // column expressions
    static let col_id       = SQLite.Expression<Int64>("CATEGID")
    static let col_name     = SQLite.Expression<String>("CATEGNAME")
    static let col_active   = SQLite.Expression<Int?>("ACTIVE")
    static let col_parentId = SQLite.Expression<Int64?>("PARENTID")

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_active,
            col_parentId
        )
    }

    static func selectData(_ row: SQLite.Row) -> CategoryData {
        return CategoryData(
            id       : row[col_id],
            name     : row[col_name],
            active   : row[col_active] ?? 0 != 0,
            parentId : row[col_parentId] ?? 0
        )
    }

    static func itemSetters(_ category: CategoryData) -> [SQLite.Setter] {
        return [
            col_name     <- category.name,
            col_active   <- category.active ? 1 : 0,
            col_parentId <- category.parentId
        ]
    }
}

extension CategoryRepository {
    // load all categories
    func load() -> [CategoryData] {
        return select(from: Self.table)
    }
}
