//
//  TransactionShareRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class TransactionShareRepository: RepositoryProtocol {
    typealias RepositoryData = TransactionShareData

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "SHAREINFO_V1"
    static let table = SQLite.Table(repositoryName)

    // column            | type    | other
    // ------------------+---------+------
    // SHAREINFOID       | INTEGER | PRIMARY KEY
    // CHECKINGACCOUNTID | INTEGER | NOT NULL
    // SHARENUMBER       | NUMERIC |
    // SHAREPRICE        | NUMERIC |
    // SHARECOMMISSION   | NUMERIC |
    // SHARELOT          | TEXT    |

    // column expressions
    static let col_id         = SQLite.Expression<Int64>("SHAREINFOID")
    static let col_transId    = SQLite.Expression<Int64>("CHECKINGACCOUNTID")
    static let col_number     = SQLite.Expression<Double?>("SHARENUMBER")
    static let col_price      = SQLite.Expression<Double?>("SHAREPRICE")
    static let col_commission = SQLite.Expression<Double?>("SHARECOMMISSION")
    static let col_lot        = SQLite.Expression<String?>("SHARELOT")

    // cast NUMERIC to REAL
    static let cast_number     = cast(col_number)     as SQLite.Expression<Double?>
    static let cast_price      = cast(col_price)      as SQLite.Expression<Double?>
    static let cast_commission = cast(col_commission) as SQLite.Expression<Double?>

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_transId,
            col_number,
            col_price,
            col_commission,
            col_lot
        )
    }

    static func selectData(_ row: SQLite.Row) -> TransactionShareData {
        return TransactionShareData(
            id         : row[col_id],
            transId    : row[col_transId],
            number     : row[cast_number] ?? 0,
            price      : row[cast_price] ?? 0,
            commission : row[cast_commission] ?? 0,
            lot        : row[col_lot] ?? ""
        )
    }

    static func itemSetters(_ data: TransactionShareData) -> [SQLite.Setter] {
        return [
            col_transId    <- data.transId,
            col_number     <- data.number,
            col_price      <- data.price,
            col_commission <- data.commission,
            col_lot        <- data.lot
        ]
    }
}

extension TransactionShareRepository {
    // load all shares
    func load() -> [TransactionShareData] {
        return select(from: Self.table
            .order(Self.col_transId, Self.col_id)
        )
    }

    // load shares of a transaction
    func load(forTransactionId transId: Int64) -> [TransactionShareData] {
        return select(from: Self.table
            .filter(Self.col_transId == transId)
            .order(Self.col_id)
        )
    }
    func load(for trans: TransactionData) -> [TransactionShareData] {
        return load(forTransactionId: trans.id)
    }
}