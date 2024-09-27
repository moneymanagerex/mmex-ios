//
//  CategoryRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SQLite

struct CategoryRepository: RepositoryProtocol {
    typealias RepositoryData = CategoryData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "CATEGORY_V1"
    static let table = SQLite.Table(repositoryName)

    // column    | type    | other
    // ----------+---------+------
    // CATEGID   | INTEGER | PRIMARY KEY
    // CATEGNAME | TEXT    | NOT NULL COLLATE NOCASE
    // ACTIVE    | INTEGER |
    // PARENTID  | INTEGER |
    //           |         | UNIQUE(CATEGNAME, PARENTID)

    // column expressions
    static let col_id       = SQLite.Expression<Int64>("CATEGID")
    static let col_name     = SQLite.Expression<String>("CATEGNAME")
    static let col_active   = SQLite.Expression<Int?>("ACTIVE")
    static let col_parentId = SQLite.Expression<Int64?>("PARENTID")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_active,
            col_parentId
        )
    }

    static func fetchData(_ row: SQLite.Row) -> CategoryData {
        return CategoryData(
            id       : row[col_id],
            name     : row[col_name],
            active   : row[col_active] ?? 0 != 0,
            parentId : row[col_parentId] ?? 0
        )
    }

    static func itemSetters(_ data: CategoryData) -> [SQLite.Setter] {
        return [
            col_name     <- data.name,
            col_active   <- data.active ? 1 : 0,
            col_parentId <- data.parentId
        ]
    }
}

extension CategoryRepository {
    // load all categories
    func load() -> [CategoryData] {
        return select(from: Self.table)
    }

    // load category of a payeer
    func pluck(for payee: PayeeData) -> CategoryData? {
        return pluck(
            from: Self.table.filter(Self.col_id == payee.categoryId),
            key: "\(payee.categoryId)"
        )
    }
}
