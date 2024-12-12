//
//  TransactionLinkRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionLinkRepository: RepositoryProtocol {
    typealias RepositoryData = TransactionLinkData

    let db: Connection

    static let repositoryName = "TRANSLINK_V1"
    static let table = SQLite.Table(repositoryName)

    // column            | type    | other
    // ------------------+---------+------
    // TRANSLINKID       | INTEGER | PRIMARY KEY
    // CHECKINGACCOUNTID | INTEGER | NOT NULL
    // LINKTYPE          | TEXT    | NOT NULL (Asset, Stock)
    // LINKRECORDID      | INTEGER | NOT NULL

    // column expressions
    static let col_id      = SQLite.Expression<Int64>("TRANSLINKID")
    static let col_transId = SQLite.Expression<Int64>("CHECKINGACCOUNTID")
    static let col_refType = SQLite.Expression<String>("LINKTYPE")
    static let col_refId   = SQLite.Expression<Int64>("LINKRECORDID")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_transId,
            col_refType,
            col_refId
        )
    }

    static func fetchData(_ row: SQLite.Row) -> TransactionLinkData {
        return TransactionLinkData(
            id      : DataId(row[col_id]),
            transId : DataId(row[col_transId]),
            refType : RefType(collateNoCase: row[col_refType]),
            refId   : DataId(row[col_refId])
        )
    }

    static func itemSetters(_ data: TransactionLinkData) -> [SQLite.Setter] {
        return [
            col_transId <- Int64(data.transId),
            col_refType <- data.refType.rawValue,
            col_refId   <- Int64(data.refId)
        ]
    }
}

extension TransactionLinkRepository {
    // load all transaction links
    func load() -> [TransactionLinkData]? {
        return select(from: Self.table
            .order(Self.col_id)
        )
    }

    // load links of a transaction
    func load(forTransactionId transId: DataId) -> [TransactionLinkData]? {
        return select(from: Self.table
            .filter(Self.col_transId == Int64(transId))
            .order(Self.col_id)
        )
    }
    func load(for trans: TransactionData) -> [TransactionLinkData]? {
        return load(forTransactionId: trans.id)
    }
}
