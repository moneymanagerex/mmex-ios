//
//  TransactionSplitRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class TransactionSplitRepository: RepositoryProtocol {
    typealias RepositoryData = TransactionSplitData

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

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

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_transId,
            col_categId,
            cast_amount,
            col_notes
        )
    }

    static func selectData(_ row: SQLite.Row) -> TransactionSplitData {
        return TransactionSplitData(
            id      : row[col_id],
            transId : row[col_transId],
            categId : row[col_categId] ?? -1,
            amount  : row[cast_amount] ?? 0,
            notes   : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ data: TransactionSplitData) -> [SQLite.Setter] {
        return [
            col_transId <- data.transId,
            col_categId <- data.categId,
            col_amount  <- data.amount,
            col_notes   <- data.notes
        ]
    }
}

extension TransactionSplitRepository {
    // load all splits
    func load() -> [TransactionSplitData] {
        return select(from: Self.table
            .order(Self.col_transId, Self.col_id)
        )
    }

    // load splits of a transaction
    func load(forTransactionId transId: Int64) -> [TransactionSplitData] {
        return select(from: Self.table
            .filter(Self.col_transId == transId)
            .order(Self.col_id)
        )
    }
    func load(for trans: TransactionData) -> [TransactionSplitData] {
        return load(forTransactionId: trans.id)
    }
}