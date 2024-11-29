//
//  ScheduledData.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

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

struct ScheduledData: DataProtocol {
    var id                : DataId            = .void
    var accountId         : DataId            = .void
    var toAccountId       : DataId            = .void
    var payeeId           : DataId            = .void
    var transCode         : TransactionType   = .defaultValue
    var transAmount       : Double            = 0.0
    var status            : TransactionStatus = .defaultValue
    var transactionNumber : String            = ""
    var notes             : String            = ""
    var categId           : DataId            = .void
    var transDate         : DateTimeString    = DateTimeString("")
    var followUpId        : Int64             = 0
    var toTransAmount     : Double            = 0.0
    var dueDate           : DateString        = DateString("")
    var repeatAuto        : RepeatAuto        = .defaultValue
    var repeatType        : RepeatType        = .defaultValue
    var repeatNum         : Int               = 0
    var color             : Int64             = 0
}

extension ScheduledData {
    static let dataName = ("Scheduled Transaction", "Scheduled Transactions")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }
}

enum RepeatTypeNum {
    case once
    case times(RepeatType, PIntInf)
    case inX(RepeatType, PInt)
    case everyX(RepeatType, PInt)
}

extension RepeatTypeNum {
    var typeNum: (RepeatType, Int) {
        return switch self {
        case .once             : (.once, -1)
        case let .times(t, n)  : (t, n.value)
        case let .inX(t, n)    : (t, n.value)
        case let .everyX(t, n) : (t, n.value)
        }
    }

    var times: PIntInf {
        return switch self {
        case .once             : PIntInf(exactly: 1)!
        case let .times(_, n)  : n
        case .inX(_, _)        : PIntInf(exactly: 2)!
        case .everyX(_, _)     : PIntInf.inf
        }
    }

    var next: Self? {
        return switch self {
        case .once             : nil
        case let .times(t, n)  : n.dec.map { .times(t, $0) }
        case .inX(_, _)        : .once
        case let .everyX(t, n) : .everyX(t, n)
        }
    }
}

extension ScheduledData {
    var repeatTypeNum: RepeatTypeNum? {
        switch repeatType {
        case .once: return .once
        case .inXDays, .inXMonths:
            let n: PInt? = PInt(exactly: repeatNum)
            return n.map { .inX(repeatType, $0) }
        case .everyXDays, .everyXMonths:
            let n: PInt? = PInt(exactly: repeatNum)
            return n.map { .everyX(repeatType, $0) }
        default:
            let n: PIntInf? = repeatNum == -1 ? PIntInf.inf : PIntInf(exactly: repeatNum)
            return n.map { .times(repeatType, $0) }
        }
    }
}

extension ScheduledData {
    static let sampleData : [ScheduledData] = [
        ScheduledData(
            id: 1, accountId: 1, payeeId: 1, transCode: TransactionType.withdrawal,
            transAmount: 10.01, status: TransactionStatus.none, categId: 1,
            transDate: DateTimeString(Date())
        ),
        ScheduledData(
            id: 2, accountId: 2, payeeId: 2, transCode: TransactionType.deposit,
            transAmount: 20.02, status: TransactionStatus.none, categId: 1,
            transDate: DateTimeString(Date())
        ),
        ScheduledData(
            id: 3, accountId: 3, payeeId: 3, transCode: TransactionType.transfer,
            transAmount: 30.03, status: TransactionStatus.none, categId: 1,
            transDate: DateTimeString(Date())
        ),
    ]
}
