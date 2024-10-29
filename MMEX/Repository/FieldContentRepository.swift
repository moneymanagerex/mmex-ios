//
//  FieldContentRepository.swift
//  MMEX
//
//  Created 2024-09-27 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct FieldContentRepository: RepositoryProtocol {
    typealias RepositoryData = FieldContentData

    let db: Connection

    static let repositoryName = "CUSTOMFIELDDATA_V1"
    static let table = SQLite.Table(repositoryName)

    // column      | type    | other
    // ------------+---------+------
    // FIELDATADID | INTEGER | PRIMARY KEY
    // REFID       | INTEGER | NOT NULL (+TRANSID, -BDID)
    // FIELDID     | INTEGER | NOT NULL
    // CONTENT     | TEXT    |
    //             |         | UNIQUE(FIELDID, REFID)

    // column expressions
    static let col_id      = SQLite.Expression<Int64>("FIELDATADID")
    static let col_refId   = SQLite.Expression<Int64>("REFID")
    static let col_fieldId = SQLite.Expression<Int64>("FIELDID")
    static let col_content = SQLite.Expression<String?>("CONTENT")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_refId,
            col_fieldId,
            col_content
        )
    }

    static func fetchData(_ row: SQLite.Row) -> FieldContentData {
        return FieldContentData(
            id      : DataId(row[col_id]),
            fieldId : DataId(row[col_fieldId]),
            refType : row[col_refId] < 0 ? RefType.scheduled : RefType.transaction,
            refId   : DataId({ x in x < 0 ? -x : x }(row[col_refId])),
            content : row[col_content] ?? ""
        )
    }

    static func itemSetters(_ data: FieldContentData) -> [SQLite.Setter] {
        return [
            col_refId   <- data.refType == RefType.scheduled ? -Int64(data.refId) : Int64(data.refId),
            col_fieldId <- Int64(data.fieldId),
            col_content <- data.content
        ]
    }
}

extension FieldContentRepository {
    // load all field content
    func load() -> [FieldContentData]? {
        return select(from: Self.table
            .order(Self.col_id)
        )
    }
}
