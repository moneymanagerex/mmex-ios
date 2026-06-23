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
    case week1
    case week2
    case month1
    case month2
    case month3
    case month6
    case year1
    case month4
    case week4
    case day1
    case dayInX
    case monthInX
    case dayEveryX
    case monthEveryX
    case month1LastDay
    case month1LastBusinessDay
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

    var splits            : [ScheduledSplitData] = []
}

extension ScheduledData {
    static let dataName = ("Scheduled Transaction", "Scheduled Transactions")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: ScheduledData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

enum RepeatTypeNum {
    case once
    case times  (RepeatType, PIntInf)
    case inX    (RepeatType, PInt)
    case everyX (RepeatType, PInt)
}

extension RepeatTypeNum {
    var type: RepeatType {
        return switch self {
        case     .once          : .once
        case let .times  (t, _) : t
        case let .inX    (t, _) : t
        case let .everyX (t, _) : t
        }
    }
    
    var num: Int {
        return switch self {
        case     .once          : -1
        case let .times  (_, n) : n.value
        case let .inX    (_, n) : n.value
        case let .everyX (_, n) : n.value
        }
    }
    
    var times: PIntInf {
        return switch self {
        case     .once          : PIntInf(exactly: 1)!
        case let .times  (_, n) : n
        case     .inX    (_, _) : PIntInf(exactly: 2)!
        case     .everyX (_, _) : PIntInf.inf
        }
    }
    
    var next: Self? {
        return switch self {
        case     .once          : nil
        case let .times  (t, n) : n.dec.map { .times(t, $0) }
        case     .inX    (_, _) : .once
        case let .everyX (t, n) : .everyX(t, n)
        }
    }

    func nextDate(_ date: Date) -> Date? {
        let cv: (Calendar.Component?, Int?) = switch type {
        case .once                   : (nil, nil)
        case .day1                  : (.day,   1)
        case .dayInX                : (.day,   num)
        case .dayEveryX             : (.day,   num)
        case .week1                 : (.day,   1*7)
        case .week2                 : (.day,   2*7)
        case .week4                 : (.day,   4*7)
        case .month1                : (.month, 1)
        case .month1LastDay         : (.month, 1)
        case .month1LastBusinessDay : (.month, 1)
        case .month2                : (.month, 2)
        case .month3                : (.month, 3)
        case .month4                : (.month, 4)
        case .month6                : (.month, 6)
        case .monthInX              : (.month, num)
        case .monthEveryX           : (.month, num)
        case .year1                 : (.year,  1)
        }

        guard let c = cv.0, let v = cv.1 else { return nil }
        let calendar = Calendar(identifier: .gregorian)
        var newDate = calendar.date(byAdding: c, value: v, to: date)!

        if type == .month1LastDay || type == .month1LastBusinessDay {
            // find the first day in next month and subtract one day
            newDate = calendar.nextDate(
                after: newDate, matching: DateComponents(day: 1),
                matchingPolicy: .nextTime, direction: .forward
            )!
            newDate = calendar.date(byAdding: .day, value: -1, to: newDate)!
        }

        if type == .month1LastBusinessDay {
            // if weekday is Sun or Sat, find the previous Fri
            let d: Int = calendar.component(.weekday, from: newDate)
            if d == 1 || d == 7 {
                newDate = calendar.nextDate(
                    after: newDate, matching: DateComponents(weekday: 6),
                    matchingPolicy: .nextTime, direction: .backward
                )!
            }
        }

        return newDate
    }
}

extension ScheduledData {
    var repeatTypeNum: RepeatTypeNum? {
        switch repeatType {
        case .once: return .once
        case .dayInX, .monthInX:
            let n: PInt? = PInt(exactly: repeatNum)
            return n.map { .inX(repeatType, $0) }
        case .dayEveryX, .monthEveryX:
            let n: PInt? = PInt(exactly: repeatNum)
            return n.map { .everyX(repeatType, $0) }
        default:
            let n: PIntInf? = repeatNum == -1 ? PIntInf.inf : PIntInf(exactly: repeatNum)
            return n.map { .times(repeatType, $0) }
        }
    }
}

extension ScheduledData {
    func nextDueDate(from currentDueDate: Date? = nil) -> Date? {
        let baseDate = currentDueDate ?? self.dueDate.optDate ?? self.transDate.optDate ?? Date()
        
        guard let repeatTypeNum = self.repeatTypeNum else {
            let date = self.dueDate.optDate ?? self.transDate.optDate
            guard let date, date > Date() else { return nil }
            return date
        }
        
        var current = baseDate
        var iterations = 0
        let maxIter = 100
        while iterations < maxIter {
            guard let next = repeatTypeNum.nextDate(current) else { return nil }
            if next > baseDate {
                return next
            }
            current = next
            iterations += 1
        }
        return nil
    }
    
    var isRecurring: Bool {
        repeatAuto != .none && repeatType != .once && repeatTypeNum != nil
    }
}

extension ScheduledData {
    static let sampleData: [ScheduledData] = {
        let today = Date()
        let calendar = Calendar.current
        
        func days(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: today)!
        }
        
        return [
            // 1. Overdue - 电费账单（7天前），每月重复，Account A -> Payee 3 (Electricity Company)
            ScheduledData(
                id: 1, accountId: 1, payeeId: 3, transCode: .withdrawal,
                transAmount: 45.50, status: .none, categId: 1,
                transDate: DateTimeString(days(-7)),
                dueDate: DateString(days(-7)),
                repeatAuto: .silent, repeatType: .month1, repeatNum: -1
            ),
            
            // 2. Overdue - 转账（4天前），每两周重复，Account A -> Account B
            ScheduledData(
                id: 2, accountId: 1, toAccountId: 2, payeeId: 0,
                transCode: .transfer, transAmount: 100.00, status: .none,
                categId: 1,
                transDate: DateTimeString(days(-4)),
                dueDate: DateString(days(-4)),
                repeatAuto: .silent, repeatType: .week2, repeatNum: -1
            ),
            
            // 3. Due Today - 宽带费，每月重复，Account B -> Payee 4 (ISP)
            ScheduledData(
                id: 3, accountId: 2, payeeId: 4, transCode: .withdrawal,
                transAmount: 29.99, status: .none, categId: 1,
                transDate: DateTimeString(days(0)),
                dueDate: DateString(days(0)),
                repeatAuto: .manual, repeatType: .month1, repeatNum: -1
            ),
            
            // 4. Due Today - 大额存款，每周重复，Account B -> Payee 1 (Payee A)
            ScheduledData(
                id: 4, accountId: 2, payeeId: 1, transCode: .deposit,
                transAmount: 99.99, status: .none, categId: 2,
                transDate: DateTimeString(days(0)),
                dueDate: DateString(days(0)),
                repeatAuto: .manual, repeatType: .week1, repeatNum: -1
            ),
            
            // 5. Due Soon（3天后）- 电话费，每月重复，Account A -> Payee 2 (Payee B)
            ScheduledData(
                id: 5, accountId: 1, payeeId: 2, transCode: .withdrawal,
                transAmount: 15.75, status: .none, categId: 2,
                transDate: DateTimeString(days(0)),
                dueDate: DateString(days(3)),
                repeatAuto: .silent, repeatType: .month1, repeatNum: -1
            ),
            
            // 6. Upcoming（10天后）- 投资账户存款，每月重复，Account B -> Payee 1 (Payee A)
            ScheduledData(
                id: 6, accountId: 2, payeeId: 1, transCode: .deposit,
                transAmount: 200.00, status: .none, categId: 1,
                transDate: DateTimeString(days(0)),
                dueDate: DateString(days(10)),
                repeatAuto: .manual, repeatType: .month1, repeatNum: -1
            ),
            
            // 7. 一次性（8天后）- 特殊付款，无重复，Account A -> Payee 3 (Electricity Company)
            ScheduledData(
                id: 7, accountId: 1, payeeId: 3, transCode: .withdrawal,
                transAmount: 55.00, status: .none, categId: 1,
                transDate: DateTimeString(days(8)),
                dueDate: DateString(days(8)),
                repeatAuto: .none, repeatType: .once, repeatNum: 0
            ),
            
            // 8. 已作废（不显示）- Account B, Payee 4, 已 void
            ScheduledData(
                id: 8, accountId: 2, payeeId: 4, transCode: .withdrawal,
                transAmount: 10.00, status: .void, categId: 2,
                transDate: DateTimeString(days(-5)),
                dueDate: DateString(days(-5)),
                repeatAuto: .none, repeatType: .once, repeatNum: 0
            ),
        ]
    }()
}
