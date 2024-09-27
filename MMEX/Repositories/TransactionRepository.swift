//
//  TransactionRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct TransactionRepository: RepositoryProtocol {
    typealias RepositoryData = TransactionData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "CHECKINGACCOUNT_V1"
    static let table = SQLite.Table(repositoryName)

    // column            | type    | other
    // ------------------+---------+------
    // TRANSID           | INTEGER | PRIMARY KEY
    // ACCOUNTID         | INTEGER | NOT NULL
    // TOACCOUNTID       | INTEGER |
    // PAYEEID           | INTEGER | NOT NULL
    // TRANSCODE         | TEXT    | NOT NULL (Withdrawal, Deposit, Transfer)
    // TRANSAMOUNT       | NUMERIC | NOT NULL
    // STATUS            | TEXT    | (N, R, V, F, D)
    // TRANSACTIONNUMBER | TEXT    |
    // NOTES             | TEXT    |
    // CATEGID           | INTEGER |
    // TRANSDATE         | TEXT    |
    // LASTUPDATEDTIME   | TEXT    |
    // DELETEDTIME       | TEXT    |
    // FOLLOWUPID        | INTEGER |
    // TOTRANSAMOUNT     | NUMERIC |
    // COLOR             | INTEGER | DEFAULT -1

    // column expressions
    static let col_id                = SQLite.Expression<Int64>("TRANSID")
    static let col_accountId         = SQLite.Expression<Int64>("ACCOUNTID")
    static let col_toAccountId       = SQLite.Expression<Int64?>("TOACCOUNTID")
    static let col_payeeId           = SQLite.Expression<Int64>("PAYEEID")
    static let col_transCode         = SQLite.Expression<String>("TRANSCODE")
    static let col_transAmount       = SQLite.Expression<Double>("TRANSAMOUNT")
    static let col_status            = SQLite.Expression<String?>("STATUS")
    static let col_transactionNumber = SQLite.Expression<String?>("TRANSACTIONNUMBER")
    static let col_notes             = SQLite.Expression<String?>("NOTES")
    static let col_categId           = SQLite.Expression<Int64?>("CATEGID")
    static let col_transDate         = SQLite.Expression<String?>("TRANSDATE")
    static let col_lastUpdatedTime   = SQLite.Expression<String?>("LASTUPDATEDTIME")
    static let col_deletedTime       = SQLite.Expression<String?>("DELETEDTIME")
    static let col_followUpId        = SQLite.Expression<Int64?>("FOLLOWUPID")
    static let col_toTransAmount     = SQLite.Expression<Double?>("TOTRANSAMOUNT")
    static let col_color             = SQLite.Expression<Int64?>("COLOR")

    // cast NUMERIC to REAL
    static let cast_transAmount   = cast(col_transAmount)   as SQLite.Expression<Double>
    static let cast_toTransAmount = cast(col_toTransAmount) as SQLite.Expression<Double?>

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_accountId,
            col_toAccountId,
            col_payeeId,
            col_transCode,
            cast_transAmount,
            col_status,
            col_transactionNumber,
            col_notes,
            col_categId,
            col_transDate,
            col_lastUpdatedTime,
            col_deletedTime,
            col_followUpId,
            cast_toTransAmount,
            col_color
        )
    }

    static func selectData(_ row: SQLite.Row) -> TransactionData {
        return TransactionData(
          id                : row[col_id],
          accountId         : row[col_accountId],
          toAccountId       : row[col_toAccountId] ?? 0,
          payeeId           : row[col_payeeId],
          transCode         : TransactionType(collateNoCase: row[col_transCode]),
          transAmount       : row[cast_transAmount],
          // TODO: case insersitive, convert either key or value
          status            : TransactionStatus(collateNoCase: row[col_status]),
          transactionNumber : row[col_transactionNumber] ?? "",
          notes             : row[col_notes] ?? "",
          categId           : row[col_categId] ?? 0,
          transDate         : row[col_transDate] ?? "",
          lastUpdatedTime   : row[col_lastUpdatedTime] ?? "",
          deletedTime       : row[col_deletedTime] ?? "",
          followUpId        : row[col_followUpId] ?? 0,
          toTransAmount     : row[cast_toTransAmount] ?? 0.0,
          color             : row[col_color] ?? 0
        )
    }

    static func itemSetters(_ data: TransactionData) -> [SQLite.Setter] {
        return [
            col_accountId         <- data.accountId,
            col_toAccountId       <- data.toAccountId,
            col_payeeId           <- data.payeeId,
            col_transCode         <- data.transCode.id,
            col_transAmount       <- data.transAmount,
            col_status            <- data.status.id,  // TODO: MMEX Desktop writes '' for .none
            col_transactionNumber <- data.transactionNumber,
            col_notes             <- data.notes,
            col_categId           <- data.categId,
            col_transDate         <- data.transDate,
            col_lastUpdatedTime   <- data.lastUpdatedTime,
            col_deletedTime       <- data.deletedTime,
            col_followUpId        <- data.followUpId,
            col_toTransAmount     <- data.toTransAmount,
            col_color             <- data.color,
        ]
    }
}

extension TransactionRepository {
    // load all transactions
    func load() -> [TransactionData] {
        return select(from: Self.table)
    }

    // load recent transactions
    func loadRecent(
        accountId: Int64? = nil,
        startDate: Date? = Calendar.current.date(byAdding: .month, value: -3, to: Date()),
        endDate: Date? = Date()
    ) -> [TransactionData] {
        var table = Self.table

        if let accountId {
            table = table.filter(Self.col_accountId == accountId || Self.col_toAccountId == accountId)
        }
        if let startDate {
            table = table.filter(Self.col_transDate >= startDate.ISO8601Format())
        }
        //if let endDate {
        //    table = table.filter(Self.col_transDate <= endDate.ISO8601Format())
        //}

        return select(from: table)
    }
}
