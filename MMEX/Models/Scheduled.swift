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
    var id                : Int64
    var accountId         : Int64
    var toAccountId       : Int64
    var payeeId           : Int64
    var transCode         : TransactionType
    var transAmount       : Double
    var status            : TransactionStatus
    var transactionNumber : String
    var notes             : String
    var categId           : Int64
    var transDate         : String
    var followUpId        : Int64
    var toTransAmount     : Double
    var dueDate           : String
    var repeatAuto        : RepeatAuto
    var repeatType        : RepeatType
    var repeatNum         : Int
    var color             : Int64

    init(
        id                : Int64             = 0,
        accountId         : Int64             = 0,
        toAccountId       : Int64             = 0,
        payeeId           : Int64             = 0,
        transCode         : TransactionType   = TransactionType.defaultValue,
        transAmount       : Double            = 0.0,
        status            : TransactionStatus = TransactionStatus.defaultValue,
        transactionNumber : String            = "",
        notes             : String            = "",
        categId           : Int64             = 0,
        transDate         : String            = "",
        followUpId        : Int64             = 0,
        toTransAmount     : Double            = 0.0,
        dueDate           : String            = "",
        repeatAuto        : RepeatAuto        = RepeatAuto.defaultValue,
        repeatType        : RepeatType        = RepeatType.defaultValue,
        repeatNum         : Int               = 0,
        color             : Int64             = 0
    ) {
        self.id                = id
        self.accountId         = accountId
        self.toAccountId       = toAccountId
        self.payeeId           = payeeId
        self.transCode         = transCode
        self.transAmount       = transAmount
        self.status            = status
        self.transactionNumber = transactionNumber
        self.notes             = notes
        self.categId           = categId
        self.transDate         = transDate
        self.followUpId        = followUpId
        self.toTransAmount     = toTransAmount
        self.dueDate           = dueDate
        self.repeatAuto        = repeatAuto
        self.repeatType        = repeatType
        self.repeatNum         = repeatNum
        self.color             = color
    }
}

extension ScheduledData: DataProtocol {
    static let modelName = "Scheduled"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

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

extension ScheduledData {
    static let sampleData : [ScheduledData] = [
        ScheduledData(
            id: 1, accountId: 1, payeeId: 1, transCode: TransactionType.withdrawal,
            transAmount: 10.01, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        ScheduledData(
            id: 2, accountId: 2, payeeId: 2, transCode: TransactionType.deposit,
            transAmount: 20.02, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        ScheduledData(
            id: 3, accountId: 3, payeeId: 3, transCode: TransactionType.transfer,
            transAmount: 30.03, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
    ]
}
