//
//  TransactionSplitRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TransactionSplitRepository: RepositoryProtocol {
    typealias RepositoryData = TransactionSplitData

    let db: Connection

    static let repositoryName = "SPLITTRANSACTIONS_V1"
    static let table = SQLite.Table(repositoryName)

    // column           | type    | other
    // -----------------+---------+------
    // SPLITTRANSID     | INTEGER | PRIMARY KEY
    // TRANSID          | INTEGER | NOT NULL
    // CATEGID          | INTEGER |
    // SPLITTRANSAMOUNT | NUMERIC |
    // NOTES            | TEXT    |

    // column expressions
    static let col_id      = SQLite.Expression<Int64>("SPLITTRANSID")
    static let col_transId = SQLite.Expression<Int64>("TRANSID")
    static let col_categId = SQLite.Expression<Int64?>("CATEGID")
    static let col_amount  = SQLite.Expression<Double?>("SPLITTRANSAMOUNT")
    static let col_notes   = SQLite.Expression<String?>("NOTES")

    // cast NUMERIC to REAL
    static let cast_amount = cast(col_amount) as SQLite.Expression<Double?>

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_transId,
            col_categId,
            cast_amount,
            col_notes
        )
    }

    static func fetchData(_ row: SQLite.Row) -> TransactionSplitData {
        return TransactionSplitData(
            id      : DataId(row[col_id]),
            transId : DataId(row[col_transId]),
            categId : DataId(row[col_categId] ?? -1),
            amount  : row[cast_amount] ?? 0,
            notes   : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ data: TransactionSplitData) -> [SQLite.Setter] {
        return [
            col_transId <- Int64(data.transId),
            col_categId <- Int64(data.categId),
            col_amount  <- data.amount,
            col_notes   <- data.notes
        ]
    }
}

extension TransactionSplitRepository {
    // load all splits
    func load() -> [TransactionSplitData]? {
        return select(from: Self.table
            .order(Self.col_transId, Self.col_id)
        )
    }

    // load splits of a transaction
    func load(forTransactionId transId: DataId) -> [TransactionSplitData]? {
        return select(from: Self.table
            .filter(Self.col_transId == Int64(transId))
            .order(Self.col_id)
        )
    }
    func load(for trans: TransactionData) -> [TransactionSplitData]? {
        return load(forTransactionId: trans.id)
    }

    func delete(_ trans: TransactionData) -> Bool {
        let splits = load(for: trans)
        guard let splits else { return false }
        var success = true
        splits.forEach { split in
            success = success && delete(split)
        }
        return success
    }

    // FIXME: delete all old splits for the given transaction and then re-create all splits
    func update(_ trans: inout TransactionData) -> Bool {
        let splits = load(for: trans)
        guard let splits else { return false }
        var success = true

        // TODO: distintish to add/update/delete
        splits.forEach { split in
            success = success && delete(split)
        }

        for i in trans.splits.indices {
            trans.splits[i].transId = trans.id
            success = success && insert(&trans.splits[i])
        }
        return success
    }
}
