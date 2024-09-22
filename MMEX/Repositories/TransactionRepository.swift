//
//  CheckingRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class TransactionRepository: RepositoryProtocol {
    typealias RepositoryItem = Transaction

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "CHECKINGACCOUNT_V1"
    static let repositoryTable = SQLite.Table(repositoryName)

    // column            | type    | other
    // ------------------+---------+------
    // TRANSID           | INTEGER | PRIMARY KEY
    // ACCOUNTID         | INTEGER | NOT NULL
    // TOACCOUNTID       | INTEGER |
    // PAYEEID           | INTEGER | NOT NULL
    // TRANSCODE         | TEXT    | NOT NULL
    // TRANSAMOUNT       | NUMERIC | NOT NULL
    // STATUS            | TEXT    |
    // TRANSACTIONNUMBER | TEXT    |
    // NOTES             | TEXT    |
    // CATEGID           | INTEGER |
    // TRANSDATE         | TEXT    |
    // LASTUPDATEDTIME   | TEXT    |
    // DELETEDTIME       | TEXT    |
    // FOLLOWUPID        | INTEGER |
    // TOTRANSAMOUNT     | NUMERIC |
    // COLOR             | INTEGER | DEFAULT -1

    // columns
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
    static let col_color             = SQLite.Expression<Int64>("COLOR")

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

    static func selectResult(_ row: SQLite.Row) -> Transaction {
        return Transaction(
          id                : row[col_id],
          accountId         : row[col_accountId],
          toAccountId       : row[col_toAccountId],
          payeeId           : row[col_payeeId],
          transCode         : Transcode(rawValue: row[col_transCode]) ?? Transcode.deposit,
          transAmount       : row[cast_transAmount],
          status            : TransactionStatus(rawValue: row[col_status] ?? "") ?? TransactionStatus.none,
          transactionNumber : row[col_transactionNumber],
          notes             : row[col_notes],
          categId           : row[col_categId],
          transDate         : row[col_transDate],
          lastUpdatedTime   : row[col_lastUpdatedTime],
          deletedTime       : row[col_deletedTime],
          followUpId        : row[col_followUpId],
          toTransAmount     : row[cast_toTransAmount],
          color             : row[col_color]
        )
    }

    static func itemSetters(_ txn: Transaction) -> [SQLite.Setter] {
        return [
            col_accountId         <- txn.accountId,
            col_toAccountId       <- txn.toAccountId,
            col_payeeId           <- txn.payeeId,
            col_transCode         <- txn.transCode.id,
            col_transAmount       <- txn.transAmount,
            col_status            <- txn.status.id,
            col_transactionNumber <- txn.transactionNumber,
            col_notes             <- txn.notes,
            col_categId           <- txn.categId,
            col_transDate         <- txn.transDate,
            col_lastUpdatedTime   <- txn.lastUpdatedTime,
            col_deletedTime       <- txn.deletedTime,
            col_followUpId        <- txn.followUpId,
            col_toTransAmount     <- txn.toTransAmount,
            col_color             <- txn.color,
        ]
    }
}

extension TransactionRepository {
    // load all transactions
    func load() -> [Transaction] {
        return select(table: Self.repositoryTable)
    }

    // load recent transactions
    func loadRecent(
        startDate: Date? = Calendar.current.date(byAdding: .month, value: -3, to: Date()),
        endDate: Date? = Date()
    ) -> [Transaction] {
        let table = if let startDate {
            Self.repositoryTable
                .filter(Self.col_transDate >= startDate.ISO8601Format())
        } else {
            Self.repositoryTable
        }
        return select(table: table)
    }
}
