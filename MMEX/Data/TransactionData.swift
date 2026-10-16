//
//  TransactionData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import Foundation
import SQLite

enum TransactionType: String, ChoiceProtocol {
    case withdrawal = "Withdrawal"
    case deposit    = "Deposit"
    case transfer   = "Transfer"
    static let defaultValue = Self.withdrawal

    var shortName: String {
        switch self { case .withdrawal: "W"; case .deposit: "D"; case .transfer: "T" }
    }
}

enum TransactionStatus: String, ChoiceProtocol {
    case none       = ""
    case reconciled = "R"
    case void       = "V"
    case followUp   = "F"
    case duplicate  = "D"
    static let defaultValue = Self.none

    var shortName: String {
        switch self { case .none: "-"; default: rawValue }
    }

    var fullName: String {
        return switch self {
        case .none       : "(none)"
        case .reconciled : "Reconciled"
        case .void       : "Void"
        case .followUp   : "Follow up"
        case .duplicate  : "Duplicate"
        }
    }

    init(collateNoCase name: String?) {
        guard let name else { self = Self.defaultValue; return }
        for x in Self.allCases {
            if x.rawValue.caseInsensitiveCompare(name) == .orderedSame ||
                x.fullName.caseInsensitiveCompare(name) == .orderedSame
            {
                self = x
                return
            }
        }
        self = Self.defaultValue
    }
}

struct TransactionData: DataProtocol {
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
    var lastUpdatedTime   : DateTimeString    = DateTimeString("")
    var deletedTime       : DateTimeString    = DateTimeString("")
    var followUpId        : Int64             = 0
    var toTransAmount     : Double            = 0.0
    var color             : Int64             = 0

    var splits            : [TransactionSplitData] = []
}

extension TransactionData {
    static let dataName = ("Transaction", "Transactions")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: TransactionData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension TransactionData {
    var day: String {
        // Extract the date portion (ignoring the time) from ISO-8601 string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format
 
        if let date = formatter.date(from: transDate.string) {
            formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
            return formatter.string(from: date)
        }
        return transDate.string // If parsing fails, return original string
    }

    var income: Double {
        // TODO: in base currency
        if transCode == .deposit {
            return transAmount
        }
        return 0.0
    }

    var expenses: Double {
        // TODO: in base currency
        if transCode == .withdrawal {
            return transAmount
        }
        return 0.0
    }

    var actual: Double {
        return switch transCode {
        case .withdrawal: 0 - transAmount;
        case .deposit: transAmount;
        default: 0.0
        }
    }

    var transfer: Double {
        // TODO: in base currency
        if transCode == .transfer {
            return transAmount// or toTransAmount
        }
        return 0.0
    }

    var isForeign: Bool {
        return !toAccountId.isVoid && transCode == .transfer
    }
    var isForeignTransfer: Bool {
        return isForeign && toAccountId == CHECKING_TYPE.AS_TRANSFER.rawValue
    }
    var isValid: Bool {
        return (
            (!payeeId.isVoid && [.withdrawal, .deposit].contains(transCode)) ||
            (!toAccountId.isVoid && transCode == .transfer)
        ) && (!categId.isVoid || splits.count >= 2)
    }
}

extension TransactionData {
    static let sampleData : [TransactionData] = {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        func timestamp(daysFromToday: Int, hour: Int, minute: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: daysFromToday, to: startOfToday) ?? startOfToday
            return calendar.date(
                bySettingHour: hour, minute: minute, second: 0, of: day
            ) ?? day
        }

        return [
            TransactionData(
                id: 1, accountId: 1, payeeId: 1, transCode: .deposit,
                transAmount: 3_200.00, status: .reconciled, categId: 2,
                transDate: DateTimeString(timestamp(daysFromToday: -12, hour: 9, minute: 0))
            ),
            TransactionData(
                id: 2, accountId: 1, payeeId: 2, transCode: .withdrawal,
                transAmount: 86.45, status: .reconciled, categId: 8,
                transDate: DateTimeString(timestamp(daysFromToday: -9, hour: 18, minute: 20))
            ),
            TransactionData(
                id: 3, accountId: 1, payeeId: 3, transCode: .withdrawal,
                transAmount: 72.40, status: .reconciled, categId: 5,
                transDate: DateTimeString(timestamp(daysFromToday: -7, hour: 8, minute: 45))
            ),
            TransactionData(
                id: 4, accountId: 1, toAccountId: 2, transCode: .transfer,
                transAmount: 450.00, status: .reconciled,
                notes: "Move money into travel savings",
                categId: 16,
                transDate: DateTimeString(timestamp(daysFromToday: -5, hour: 20, minute: 15))
            ),
            TransactionData(
                id: 5, accountId: 1, payeeId: 6, transCode: .withdrawal,
                transAmount: 58.20, status: .reconciled,
                notes: "Weekend outing",
                transDate: DateTimeString(timestamp(daysFromToday: -3, hour: 12, minute: 10)),
                splits: TransactionSplitData.sampleData
            ),
            TransactionData(
                id: 6, accountId: 1, payeeId: 5, transCode: .withdrawal,
                transAmount: 18.50, status: .reconciled, categId: 10,
                transDate: DateTimeString(timestamp(daysFromToday: -2, hour: 7, minute: 50))
            ),
            TransactionData(
                id: 7, accountId: 1, payeeId: 8, transCode: .deposit,
                transAmount: 420.00, status: .reconciled, categId: 3,
                transDate: DateTimeString(timestamp(daysFromToday: -1, hour: 15, minute: 25))
            ),
            TransactionData(
                id: 8, accountId: 1, payeeId: 6, transCode: .withdrawal,
                transAmount: 14.20, status: .reconciled, categId: 12,
                transDate: DateTimeString(timestamp(daysFromToday: 0, hour: 9, minute: 35))
            ),
            TransactionData(
                id: 9, accountId: 3, payeeId: 7, transCode: .withdrawal,
                transAmount: 306.20, status: .reconciled, notes: "Initial ETF purchase", categId: 14,
                transDate: DateTimeString(timestamp(daysFromToday: -45, hour: 10, minute: 0))
            ),
            TransactionData(
                id: 10, accountId: 3, payeeId: 7, transCode: .withdrawal,
                transAmount: 1_355.60, status: .reconciled, notes: "Increase long-term holdings", categId: 14,
                transDate: DateTimeString(timestamp(daysFromToday: -15, hour: 14, minute: 40))
            ),
        ]
    }()
}
