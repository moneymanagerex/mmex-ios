//
//  TagRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class TagRepository: RepositoryProtocol {
    typealias RepositoryData = TagData

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "TAG_V1"
    static let table = SQLite.Table(repositoryName)

    // column  | type    | other
    // --------+---------+------
    // TAGID   | INTEGER | PRIMARY KEY
    // TAGNAME | TEXT    | NOT NULL UNIQUE COLLATE NOCASE
    // ACTIVE  | INTEGER |

    // column expressions
    static let col_id     = SQLite.Expression<Int64>("TAGID")
    static let col_name   = SQLite.Expression<String>("TAGNAME")
    static let col_active = SQLite.Expression<Int?>("ACTIVE")

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_active
        )
    }

    static func selectData(_ row: SQLite.Row) -> TagData {
        return TagData(
            id     : row[col_id],
            name   : row[col_name],
            active : row[col_active] ?? 0 != 0
        )
    }

    static func itemSetters(_ tag: TagData) -> [SQLite.Setter] {
        return [
            col_name   <- tag.name,
            col_active <- tag.active ? 1 : 0
        ]
    }
}

extension TagRepository {
    // load all tags
    func load() -> [TagData] {
        return select(from: Self.table
            .order(Self.col_name)
        )
    }
}
