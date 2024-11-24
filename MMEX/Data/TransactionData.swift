//
//  TransactionData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import Foundation
import SQLite

enum TransactionType: String, EnumCollateNoCase {
    case withdrawal = "Withdrawal"
    case deposit    = "Deposit"
    case transfer   = "Transfer"
    static let defaultValue = Self.withdrawal

    var shortName: String {
        switch self { case .withdrawal: "W"; case .deposit: "D"; case .transfer: "T" }
    }
}

enum TransactionStatus: String, EnumCollateNoCase {
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
    static let sampleData : [TransactionData] = [
        TransactionData(
            id: 1, accountId: 1, payeeId: 1, transCode: TransactionType.withdrawal,
            transAmount: 10.01, status: TransactionStatus.reconciled, categId: 1,
            transDate: DateTimeString(Date())
        ),
        TransactionData(
            id: 2, accountId: 2, payeeId: 2, transCode: TransactionType.deposit,
            transAmount: 20.02, status: TransactionStatus.void, categId: 1,
            transDate: DateTimeString(Date())
        ),
        TransactionData(
            id: 3, accountId: 3, toAccountId: 2, transCode: TransactionType.transfer,
            transAmount: 30.03, status: TransactionStatus.followUp,
            notes: "transfer transacion data",
            categId: 1,
            transDate: DateTimeString(Date())
        ),
        TransactionData(
            id: 4, accountId: 3, payeeId: 2, transCode: TransactionType.withdrawal,
            transAmount: 40.04, status: TransactionStatus.duplicate,
            notes: "split transacion data",
            transDate: DateTimeString(Date()),
            splits: TransactionSplitData.sampleData
        ),
    ]
}
