//
//  CheckingRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class TransactionRepository {
    let db: Connection?
    
    init(db: Connection?) {
        self.db = db
    }
}

extension TransactionRepository {
    // table query
    static let table = SQLite.Table("CHECKINGACCOUNT_V1")

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

    // table columns
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
}
    
extension TransactionRepository {
    // select query
    static func selectQuery(from: SQLite.Table) -> SQLite.Table {
        return from.select(
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

    // select result
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

    static func insertSetters(_ txn: Transaction) -> [Setter] {
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

    // insert query
    static func insertQuery(_ txn: Transaction) -> SQLite.Insert {
        return table.insert(insertSetters(txn))
    }

    // update query
    static func updateQuery(_ txn: Transaction) -> SQLite.Update {
        return table.filter(col_id == txn.id).update(insertSetters(txn))
    }

    // delete query
    static func deleteQuery(_ txn: Transaction) -> SQLite.Delete {
        return table.filter(col_id == txn.id).delete()
    }
}

extension TransactionRepository {
    // load all transactions
    func loadTransactions() -> [Transaction] {
        guard let db else { return [] }
        do {
            var results: [Transaction]   = []
            let query = TransactionRepository.selectQuery(from: TransactionRepository.table)
            for row in try db.prepare(query) {
                results.append(TransactionRepository.selectResult(row))
            }
            print("Successfully loaded transactions: \(results.count)")
            return results
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }

    // load recent transactions
    func loadRecentTransactions(
        startDate: Date? = Calendar.current.date(byAdding: .month, value: -3, to: Date()),
        endDate: Date? = Date()
    ) -> [Transaction] {
        guard let db else { return [] }
        do {
            var results: [Transaction] = []
            var from = TransactionRepository.table
            // If startDate is set, add filtering by date range
            if let startDate {
                from = from.filter(TransactionRepository.col_transDate >= startDate.ISO8601Format())
            }
            let query = TransactionRepository.selectQuery(from: from)
            for row in try db.prepare(query) {
                results.append(TransactionRepository.selectResult(row))
            }
            print("Successfully loaded transactions: \(results.count)")
            return results
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }

    // add a new transaction
    func addTransaction(txn: inout Transaction) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(TransactionRepository.insertQuery(txn))
            txn.id = rowid
            print("Successfully added transaction with ID: \(txn.id), \(txn)")
            return true
        } catch {
            print("Failed to add transaction: \(error)")
            return false
        }
    }

    // update an existing transaction
    func updateTransaction(txn: Transaction) -> Bool {
        guard let db else { return false }
        do {
            try db.run(TransactionRepository.updateQuery(txn))
            print("Successfully updated transaction: \(txn.id)")
            return true
        } catch {
            print("Failed to update transaction: \(error)")
            return false
        }
    }
    
    func deleteTransaction(txn: Transaction) -> Bool {
        guard let db else { return false }
        do {
            try db.run(TransactionRepository.deleteQuery(txn))
            print("Successfully deleted transaction: \(txn.id)")
            return true
        } catch {
            print("Failed to delete transaction: \(error)")
            return false
        }
    }
}
