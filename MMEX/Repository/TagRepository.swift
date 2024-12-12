//
//  TagRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagRepository: RepositoryProtocol {
    typealias RepositoryData = TagData
    
    let db: Connection
    
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
    
    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_active
        )
    }
    
    static func fetchData(_ row: SQLite.Row) -> TagData {
        return TagData(
            id     : DataId(row[col_id]),
            name   : row[col_name],
            active : row[col_active] ?? 0 != 0
        )
    }
    
    static func itemSetters(_ data: TagData) -> [SQLite.Setter] {
        return [
            col_name   <- data.name,
            col_active <- data.active ? 1 : 0
        ]
    }

    static func filterUsed(_ table: SQLite.Table) -> SQLite.Table {
        typealias GL = TagLinkRepository
        let cond = "EXISTS (" + (GL.table.select(1).where(
            GL.table[GL.col_tagId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }
}

extension TagRepository {
    // load tags of a specific item
    func load(for trans: TransactionData) -> [String]? {
        typealias G = TagRepository
        typealias L = TagLinkRepository
        typealias T = TransactionRepository
        return Repository(db).select(from: G.table
            .join(L.table, on: L.table[L.col_tagId] == G.table[G.col_id])
            .join(T.table, on: T.table[T.col_id] == L.table[L.col_refId])
            .filter(L.table[L.col_refType] == RefType.transaction.rawValue)
            .filter(T.table[T.col_id] == Int64(trans.id))
            .order(L.table[L.col_id])
        ) { row in
            row[G.table[G.col_name]]
        }
    }

    func load(for sched: ScheduledData) -> [String]? {
        typealias G = TagRepository
        typealias L = TagLinkRepository
        typealias T = ScheduledRepository
        return Repository(db).select(from: G.table
            .join(L.table, on: L.table[L.col_tagId] == G.table[G.col_id])
            .join(T.table, on: T.table[T.col_id] == L.table[L.col_refId])
            .filter(L.table[L.col_refType] == RefType.scheduled.rawValue)
            .filter(T.table[T.col_id] == Int64(sched.id))
            .order(L.table[L.col_id])
        ) { row in
            row[G.table[G.col_name]]
        }
    }
}
