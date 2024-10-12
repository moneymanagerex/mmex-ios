//
//  ScheduledSplitRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct ScheduledSplitRepository: RepositoryProtocol {
    typealias RepositoryData = ScheduledSplitData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "BUDGETSPLITTRANSACTIONS_V1"
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

    static func fetchData(_ row: SQLite.Row) -> ScheduledSplitData {
        return ScheduledSplitData(
            id      : DataId(row[col_id]),
            schedId : DataId(row[col_transId]),
            categId : DataId(row[col_categId] ?? -1),
            amount  : row[cast_amount] ?? 0,
            notes   : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ data: ScheduledSplitData) -> [SQLite.Setter] {
        return [
            col_transId <- Int64(data.schedId),
            col_categId <- Int64(data.categId),
            col_amount  <- data.amount,
            col_notes   <- data.notes
        ]
    }
}

extension ScheduledSplitRepository {
    // load all splits
    func load() -> [ScheduledSplitData]? {
        return select(from: Self.table
            .order(Self.col_transId, Self.col_id)
        )
    }

    // load splits of a scheduled transaction
    func load(forScheduledId schedId: DataId) -> [ScheduledSplitData]? {
        return select(from: Self.table
            .filter(Self.col_transId == Int64(schedId))
            .order(Self.col_id)
        )
    }
    func load(for sched: ScheduledData) -> [ScheduledSplitData]? {
        return load(forScheduledId: sched.id)
    }
}
