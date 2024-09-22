//
//  PayeeRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class PayeeRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }
}

extension PayeeRepository: RepositoryProtocol {
    typealias RepositoryItem = Payee

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

    // table columns
    static let col_id         = SQLite.Expression<Int64>("PAYEEID")
    static let col_name       = SQLite.Expression<String>("PAYEENAME")
    static let col_categoryId = SQLite.Expression<Int64?>("CATEGID")
    static let col_number     = SQLite.Expression<String?>("NUMBER")
    static let col_website    = SQLite.Expression<String?>("WEBSITE")
    static let col_notes      = SQLite.Expression<String?>("NOTES")
    static let col_active     = SQLite.Expression<Int?>("ACTIVE")
    static let col_pattern    = SQLite.Expression<String>("PATTERN")

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
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

    static func selectResult(_ row: SQLite.Row) -> Payee {
        return Payee(
            id         : row[col_id],
            name       : row[col_name],
            categoryId : row[col_categoryId],
            number     : row[col_number],
            website    : row[col_website],
            notes      : row[col_notes],
            active     : row[col_active] ?? 1,
            pattern    : row[col_pattern]
        )
    }

    static func itemSetters(_ payee: Payee) -> [SQLite.Setter] {
        return [
            col_name       <- payee.name,
            col_categoryId <- payee.categoryId,
            col_number     <- payee.number,
            col_website    <- payee.website,
            col_notes      <- payee.notes,
            col_active     <- payee.active,
            col_pattern    <- payee.pattern
        ]
    }
}

extension PayeeRepository {
    func load() -> [Payee] {
        return select(table: Self.table
            .order(Self.col_active.desc, Self.col_name)
        )
    }
}
