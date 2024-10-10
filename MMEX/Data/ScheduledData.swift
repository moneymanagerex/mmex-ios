//
//  Scheduled.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import SQLite
import Foundation

enum RepeatAuto: Int, CaseIterable, Identifiable, Codable {
    case none = 0
    case manual
    case silent
    static let defaultValue = Self.none

    static let names = [
        "None",
        "Manual",
        "Silent"
    ]
    var id: Int { self.rawValue }
    var name: String { Self.names[self.rawValue] }
}

enum RepeatType: Int, CaseIterable, Identifiable, Codable {
    case once = 0
    case weekly
    case every2Weeks
    case monthly
    case every2Months
    case every3Months
    case every6Months
    case yearly
    case every4Months
    case every4Weeks
    case daily
    case inXDays
    case inXMonths
    case everyXDays
    case everyXMonths
    case monthlyLastDay
    case monthlyLastBusinessDay
    static let defaultValue = Self.once

    static let names = [
        "Once",
        "Weekly",
        "Fortnightly",
        "Monthly",
        "Every 2 Months",
        "Quarterly",
        "Half-Yearly",
        "Yearly",
        "Four Months",
        "Four Weeks",
        "Daily",
        "In (n) Days",
        "In (n) Months",
        "Every (n) Days",
        "Every (n) Months",
        "Monthly (last day)",
        "Monthly (last business day)",
    ]
    var id: Int { self.rawValue }
    var name: String { Self.names[self.rawValue] }
}

struct ScheduledData: ExportableEntity {
    var id                : Int64             = 0
    var accountId         : Int64             = 0
    var toAccountId       : Int64             = 0
    var payeeId           : Int64             = 0
    var transCode         : TransactionType   = TransactionType.defaultValue
    var transAmount       : Double            = 0.0
    var status            : TransactionStatus = TransactionStatus.defaultValue
    var transactionNumber : String            = ""
    var notes             : String            = ""
    var categId           : Int64             = 0
    var transDate         : DateTimeString    = DateTimeString("")
    var followUpId        : Int64             = 0
    var toTransAmount     : Double            = 0.0
    var dueDate           : DateString        = DateString("")
    var repeatAuto        : RepeatAuto        = RepeatAuto.defaultValue
    var repeatType        : RepeatType        = RepeatType.defaultValue
    var repeatNum         : Int               = 0
    var color             : Int64             = 0
}

extension ScheduledData: DataProtocol {
    static let dataName = "Scheduled"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

/* TODO: move to ViewModels
struct ScheduledFull: FullProtocol {
    var data: ScheduledData
    var accountName       : String?
    var accountCurrency   : CurrencyData?
    var toAccountName     : String?
    var toAccountCurrency : String?
    var categoryName      : String?
    var payeeName         : String?
  //var tags              : [TagData]
  //var fields            : [(FieldData, String?)]
}
*/

extension ScheduledData {
    static let sampleData : [ScheduledData] = [
        ScheduledData(
            id: 1, accountId: 1, payeeId: 1, transCode: TransactionType.withdrawal,
            transAmount: 10.01, status: TransactionStatus.unreconciled, categId: 1,
            transDate: DateTimeString(Date())
        ),
        ScheduledData(
            id: 2, accountId: 2, payeeId: 2, transCode: TransactionType.deposit,
            transAmount: 20.02, status: TransactionStatus.unreconciled, categId: 1,
            transDate: DateTimeString(Date())
        ),
        ScheduledData(
            id: 3, accountId: 3, payeeId: 3, transCode: TransactionType.transfer,
            transAmount: 30.03, status: TransactionStatus.unreconciled, categId: 1,
            transDate: DateTimeString(Date())
        ),
    ]
}
