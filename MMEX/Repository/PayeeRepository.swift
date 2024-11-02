//
//  PayeeRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct PayeeRepository: RepositoryProtocol {
    typealias RepositoryData = PayeeData

    let db: Connection

    static let repositoryName = "PAYEE_V1"
    static let table = SQLite.Table(repositoryName)

    // column    | type    | other
    // ----------+---------+------
    // PAYEEID   | INTEGER | PRIMARY KEY
    // PAYEENAME | TEXT    | NOT NULL COLLATE NOCASE UNIQUE
    // CATEGID   | INTEGER |
    // NUMBER    | TEXT    |
    // WEBSITE   | TEXT    |
    // NOTES     | TEXT    |
    // ACTIVE    | INTEGER |
    // PATTERN   | TEXT    | DEFAULT ''

    // column expressions
    static let col_id         = SQLite.Expression<Int64>("PAYEEID")
    static let col_name       = SQLite.Expression<String>("PAYEENAME")
    static let col_categoryId = SQLite.Expression<Int64?>("CATEGID")
    static let col_number     = SQLite.Expression<String?>("NUMBER")
    static let col_website    = SQLite.Expression<String?>("WEBSITE")
    static let col_notes      = SQLite.Expression<String?>("NOTES")
    static let col_active     = SQLite.Expression<Int?>("ACTIVE")
    static let col_pattern    = SQLite.Expression<String?>("PATTERN")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_categoryId,
            col_number,
            col_website,
            col_notes,
            col_active,
            col_pattern
        )
    }

    static func fetchData(_ row: SQLite.Row) -> PayeeData {
        return PayeeData(
            id         : DataId(row[col_id]),
            name       : row[col_name],
            categoryId : DataId(row[col_categoryId] ?? -1),
            number     : row[col_number] ?? "",
            website    : row[col_website] ?? "",
            notes      : row[col_notes] ?? "",
            active     : row[col_active] ?? 0 != 0,
            pattern    : row[col_pattern] ?? ""
        )
    }

    static func itemSetters(_ data: PayeeData) -> [SQLite.Setter] {
        return [
            col_name       <- data.name,
            col_categoryId <- Int64(data.categoryId),
            col_number     <- data.number,
            col_website    <- data.website,
            col_notes      <- data.notes,
            col_active     <- data.active ? 1 : 0,
            col_pattern    <- data.pattern
        ]
    }

    static func filterUsed(_ table: SQLite.Table) -> SQLite.Table {
        typealias T = TransactionRepository
        typealias R = ScheduledRepository
        let cond = "EXISTS (" + (T.table.select(1).where(
            T.table[T.col_payeeId] == Self.table[Self.col_id]
        ) ).union(R.table.select(1).where(
            R.table[R.col_payeeId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }

    static func filterDeps(_ table: SQLite.Table) -> SQLite.Table {
        typealias AX = AttachmentRepository
        let cond = "EXISTS (" + (AX.table.select(1).where(
            AX.table[AX.col_refType] == RefType.account.rawValue &&
            AX.table[AX.col_refId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }
}

extension PayeeRepository {
    // load all payees
    func load() -> [PayeeData]? {
        return select(from: Self.table
            .order(Self.col_active.desc, Self.col_name)
        )
    }
}
