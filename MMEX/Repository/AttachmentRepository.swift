//
//  AttachmentRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct AttachmentRepository: RepositoryProtocol {
    typealias RepositoryData = AttachmentData

    let db: Connection
    let databaseName: String

    static let repositoryName = "ATTACHMENT_V1"
    static let table = SQLite.Table(repositoryName)

    // column       | type    | other
    // -------------+---------+------
    // ATTACHMENTID | INTEGER | PRIMARY KEY
    // REFTYPE      | TEXT    | NOT NULL (BankAccount, Asset, Stock, ...)
    // REFID        | INTEGER | NOT NULL
    // DESCRIPTION  | TEXT    | COLLATE NOCASE
    // FILENAME     | TEXT    | NOT NULL COLLATE NOCASE

    // column expressions
    static let col_id          = SQLite.Expression<Int64>("ATTACHMENTID")
    static let col_refType     = SQLite.Expression<String>("REFTYPE")
    static let col_refId       = SQLite.Expression<Int64>("REFID")
    static let col_description = SQLite.Expression<String?>("DESCRIPTION")
    static let col_filename    = SQLite.Expression<String>("FILENAME")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_refType,
            col_refId,
            col_description,
            col_filename
        )
    }

    static func fetchData(_ row: SQLite.Row) -> AttachmentData {
        return AttachmentData(
            id          : DataId(row[col_id]),
            refType     : RefType(collateNoCase: row[col_refType]),
            refId       : DataId(row[col_refId]),
            description : row[col_description] ?? "",
            filename    : row[col_filename]
        )
    }

    static func itemSetters(_ data: AttachmentData) -> [SQLite.Setter] {
        return [
            col_refType     <- data.refType.rawValue,
            col_refId       <- Int64(data.refId),
            col_description <- data.description,
            col_filename    <- data.filename
        ]
    }
}

extension AttachmentRepository {
    func delete(refType: RefType, refId: DataId) -> Bool {
        do {
            let query = Self.table
                .filter(Self.col_refType == refType.rawValue && Self.col_refId == Int64(refId))
                .delete()
            log.trace("DEBUG: AttachmentRepository.delete(main=\(Thread.isMainThread)): \(query.expression.description)")
            try db.run(query)
            log.info("INFO: AttachmentRepository.delete(\(Self.repositoryName))")
            return true
        } catch {
            log.error("ERROR: AttachmentRepository.delete(\(Self.repositoryName)): \(error)")
            return false
        }
    }
}
