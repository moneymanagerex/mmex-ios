//
//  FieldRepository.swift
//  MMEX
//
//  Created 2024-09-27 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct FieldRepository: RepositoryProtocol {
    typealias RepositoryData = FieldData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "CUSTOMFIELD_V1"
    static let table = SQLite.Table(repositoryName)

    // column      | type    | other
    // ------------+---------+------
    // FIELDID     | INTEGER | PRIMARY KEY
    // REFTYPE     | TEXT    | NOT NULL (Transaction, RecurringTransaction)
    // DESCRIPTION | TEXT    | COLLATE NOCASE
    // TYPE        | TEXT    | NOT NULL (String, Integer, Decimal, ...)
    // PROPERTIES  | TEXT    | NOT NULL

    // column expressions
    static let col_id          = SQLite.Expression<Int64>("FIELDID")
    static let col_refType     = SQLite.Expression<String>("REFTYPE")
    static let col_description = SQLite.Expression<String?>("DESCRIPTION")
    static let col_type        = SQLite.Expression<String>("TYPE")
    static let col_properties  = SQLite.Expression<String>("PROPERTIES")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_refType,
            col_description,
            col_type,
            col_properties
        )
    }

    static func fetchData(_ row: SQLite.Row) -> FieldData {
        return FieldData(
            id          : DataId(row[col_id]),
            refType     : RefType(collateNoCase: row[col_refType]),
            description : row[col_description] ?? "",
            type        : FieldType(collateNoCase: row[col_type]),
            properties  : row[col_properties]
        )
    }

    static func itemSetters(_ data: FieldData) -> [SQLite.Setter] {
        return [
            col_refType     <- data.refType.rawValue,
            col_description <- data.description,
            col_type        <- data.type.rawValue,
            col_properties  <- data.properties
        ]
    }
}

extension FieldRepository {
    // load all fields
    func load() -> [FieldData] {
        return select(from: Self.table
            .order(Self.col_id)
        )
    }
}
