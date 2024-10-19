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
            id       : DataId(row[col_id]),
            name     : row[col_name],
            active   : row[col_active] ?? 0 != 0,
            parentId : DataId(row[col_parentId] ?? 0)
        )
    }

    static func itemSetters(_ data: CategoryData) -> [SQLite.Setter] {
        return [
            col_name     <- data.name,
            col_active   <- data.active ? 1 : 0,
            col_parentId <- Int64(data.parentId)
        ]
    }

    static func filterUsed(_ table: SQLite.Table) -> SQLite.Table {
        typealias C = CategoryRepository
        typealias P = PayeeRepository
        typealias T = TransactionRepository
        typealias TS = TransactionSplitRepository
        typealias R = ScheduledRepository
        typealias RS = ScheduledSplitRepository
        typealias B = BudgetTableRepository
        let CP_table: SQLite.Table = C.table.alias("Parent")

        // problem: compiler cannot determine the type with too many union terms
        // fix: split union in two parts
        let cond1 = "EXISTS (" + (CP_table.select(1).where(
            CP_table[C.col_parentId] == Self.table[Self.col_id]
        ) ).union(P.table.select(1).where(
            P.table[P.col_categoryId] == Self.table[Self.col_id]
        ) ).expression.description + ")"

        let cond2 = "EXISTS (" + (T.table.select(1).where(
            T.table[T.col_categId] == Self.table[Self.col_id]
        ) ).union(TS.table.select(1).where(
            TS.table[TS.col_categId] == Self.table[Self.col_id]
        ) ).union(R.table.select(1).where(
            R.table[R.col_categId] == Self.table[Self.col_id]
        ) ).union(RS.table.select(1).where(
            RS.table[RS.col_categId] == Self.table[Self.col_id]
        ) ).union(B.table.select(1).where(
            B.table[B.col_categId] == Self.table[Self.col_id]
        ) ).expression.description + ")"

        return table.filter(SQLite.Expression<Bool>(literal: cond1))
            .union(table.filter(SQLite.Expression<Bool>(literal: cond2)))
    }
}

extension CategoryRepository {
    // load all categories
    func load() -> [CategoryData]? {
        return select(from: Self.table)
    }

    // load category of a payee
    func pluck(for payee: PayeeData) -> RepositoryPluckResult<CategoryData> {
        return pluck(
            key: "\(payee.categoryId)",
            from: Self.table.filter(Self.col_id == Int64(payee.categoryId))
        )
    }
}
