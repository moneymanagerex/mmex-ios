//
//  ScheduledRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class ScheduledRepository: RepositoryProtocol {
    typealias RepositoryData = ScheduledData
    typealias RepositoryFull = ScheduledFull

    let db: Connection?
    var accountDict  : [Int64: (String, CurrencyData?)] = [:]
    var categoryDict : [Int64: String] = [:]
    var payeeDict    : [Int64: String] = [:]
  //var tagDict      : [Int64: String] = [:]
  //var fieldDict    : [Int64: FieldData] = [:]

    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "BILLSDEPOSITS_V1"
    static let repositoryTable = SQLite.Table(repositoryName)

    // column             | type    | other
    // -------------------+---------+------
    // BDID               | INTEGER | PRIMARY KEY
    // ACCOUNTID          | INTEGER | NOT NULL
    // TOACCOUNTID        | INTEGER |
    // PAYEEID            | INTEGER | NOT NULL
    // TRANSCODE          | TEXT    | NOT NULL (Withdrawal, Deposit, Transfer)
    // TRANSAMOUNT        | NUMERIC | NOT NULL
    // STATUS             | TEXT    | (Unreconciled, Reconciled, Void, Follow up, Duplicate)
    // TRANSACTIONNUMBER  | TEXT    |
    // NOTES              | TEXT    |
    // CATEGID            | INTEGER |
    // TRANSDATE          | TEXT    |
    // FOLLOWUPID         | INTEGER |
    // TOTRANSAMOUNT      | NUMERIC |
    // REPEATS            | INTEGER |
    // NEXTOCCURRENCEDATE | TEXT    |
    // NUMOCCURRENCES     | INTEGER |
    // COLOR              | INTEGER | DEFAULT -1

    // columns
    static let col_id                 = SQLite.Expression<Int64>("BDID")
    static let col_accountId          = SQLite.Expression<Int64>("ACCOUNTID")
    static let col_toAccountId        = SQLite.Expression<Int64?>("TOACCOUNTID")
    static let col_payeeId            = SQLite.Expression<Int64>("PAYEEID")
    static let col_transCode          = SQLite.Expression<String>("TRANSCODE")
    static let col_transAmount        = SQLite.Expression<Double>("TRANSAMOUNT")
    static let col_status             = SQLite.Expression<String?>("STATUS")
    static let col_transactionNumber  = SQLite.Expression<String?>("TRANSACTIONNUMBER")
    static let col_notes              = SQLite.Expression<String?>("NOTES")
    static let col_categId            = SQLite.Expression<Int64?>("CATEGID")
    static let col_transDate          = SQLite.Expression<String?>("TRANSDATE")
    static let col_followUpId         = SQLite.Expression<Int64?>("FOLLOWUPID")
    static let col_toTransAmount      = SQLite.Expression<Double?>("TOTRANSAMOUNT")
    static let col_repeats            = SQLite.Expression<Int64?>("REPEATS")
    static let col_nextOccurrenceDate = SQLite.Expression<String?>("NEXTOCCURRENCEDATE")
    static let col_numOccurrences     = SQLite.Expression<Int64?>("NUMOCCURRENCES")
    static let col_color              = SQLite.Expression<Int64?>("COLOR")

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
            col_followUpId,
            cast_toTransAmount,
            col_repeats,
            col_nextOccurrenceDate,
            col_numOccurrences,
            col_color
        )
    }

    static let repeatBase = 100

    static func selectData(_ row: SQLite.Row) -> ScheduledData {
        return ScheduledData(
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
          followUpId        : row[col_followUpId] ?? 0,
          toTransAmount     : row[cast_toTransAmount] ?? 0.0,
          dueDate           : row[col_nextOccurrenceDate] ?? "",
          repeatAuto        : RepeatAuto(rawValue: Int(row[col_repeats] ?? 0) / repeatBase) ?? RepeatAuto.defaultValue,
          repeatType        : RepeatType(rawValue: Int(row[col_repeats] ?? 0) % repeatBase) ?? RepeatType.defaultValue,
          repeatNum         : Int(row[col_numOccurrences] ?? 0),
          color             : row[col_color] ?? 0
        )
    }

    func selectFull(_ row: SQLite.Row) -> ScheduledFull {
        let full = ScheduledFull(
            data: Self.selectData(row)
        )
        return full
    }

    static func itemSetters(_ sched: ScheduledData) -> [SQLite.Setter] {
        let repeats = sched.repeatAuto.rawValue * repeatBase + sched.repeatType.rawValue
        return [
            col_accountId          <- sched.accountId,
            col_toAccountId        <- sched.toAccountId,
            col_payeeId            <- sched.payeeId,
            col_transCode          <- sched.transCode.id,
            col_transAmount        <- sched.transAmount,
            col_status             <- sched.status.id,
            col_transactionNumber  <- sched.transactionNumber,
            col_notes              <- sched.notes,
            col_categId            <- sched.categId,
            col_transDate          <- sched.transDate,
            col_followUpId         <- sched.followUpId,
            col_toTransAmount      <- sched.toTransAmount,
            col_repeats            <- Int64(repeats),
            col_nextOccurrenceDate <- sched.dueDate,
            col_numOccurrences     <- Int64(sched.repeatNum),
            col_color              <- sched.color,
        ]
    }
}

extension ScheduledRepository {
    // load data from all scheduled transactions
    func load() -> [ScheduledData] {
        return selectData(from: Self.repositoryTable)
    }

    // load full data from all scheduled transactions
    func loadFull(from table: SQLite.Table) -> [ScheduledFull] {
        return selectFull(from: Self.repositoryTable)
    }
}