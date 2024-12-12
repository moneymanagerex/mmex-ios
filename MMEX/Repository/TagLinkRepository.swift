//
//  TagLinkRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagLinkRepository: RepositoryProtocol {
    typealias RepositoryData = TagLinkData

    let db: Connection
    let databaseName: String

    static let repositoryName = "TAGLINK_V1"
    static let table = SQLite.Table(repositoryName)

    // column              | type    | other
    // --------------------+---------+------
    // TAGLINKID | INTEGER | PRIMARY KEY
    // REFTYPE   | TEXT    | NOT NULL (Transaction, TransactionSplit, ...)
    // REFID     | INTEGER | NOT NULL
    // TAGID     | INTEGER | NOT NULL
    //           |         | UNIQUE(REFTYPE, REFID, TAGID)

    // column expressions
    static let col_id      = SQLite.Expression<Int64>("TAGLINKID")
    static let col_tagId   = SQLite.Expression<Int64>("TAGID")
    static let col_refType = SQLite.Expression<String>("REFTYPE")
    static let col_refId   = SQLite.Expression<Int64>("REFID")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_tagId,
            col_refType,
            col_refId
        )
    }

    static func fetchData(_ row: SQLite.Row) -> TagLinkData {
        return TagLinkData(
            id      : DataId(row[col_id]),
            tagId   : DataId(row[col_tagId]),
            refType : RefType(collateNoCase: row[col_refType]),
            refId   : DataId(row[col_refId])
        )
    }

    static func itemSetters(_ data: TagLinkData) -> [SQLite.Setter] {
        return [
            col_tagId   <- Int64(data.tagId),
            col_refType <- data.refType.rawValue,
            col_refId   <- Int64(data.refId)
        ]
    }
}
