//
//  JournalData.swift
//  MMEX
//
//  2024-11-03: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

// JournalData represents one of the following:
// * an already executed transaction (similar to TransactionData)
// * a future execution of a scheduled transaction (similar to TransactionData)
// * a scheduled transaction (similar to ScheduledData)
//
// For easier access to fields, the data structure is flattened, i.e.,
// there are no associated enum values.

enum JournalType: Int, CaseIterable, Identifiable, Codable {
    case transaction = 0
    case future
    case scheduled
    static let defaultValue = Self.transaction

    static let names = [
        "Transaction",
        "Future",
        "Scheduled"
    ]
    var id: Int { self.rawValue }
    var name: String { Self.names[self.rawValue] }
}

struct JournalData: ExportableEntity {
    // type == .transaction:
    //   transactionId : same as TransactionData.id
    //   scheduledId   = .void
    //   sequence      = 0
    // type == .future
    //   transactionId = .void
    //   scheduledId   : same as ScheduledData.id of the original scheduled transaction
    //   sequence      > 0 (1 represents the first future execution)
    // type == .scheduled
    //   transactionId = .void
    //   scheduledId   : same as ScheduledData.id
    //   sequence      = 0
    var type              : JournalType       = .defaultValue
    var transactionId     : DataId            = .void
    var scheduledId       : DataId            = .void
    var sequence          : Int               = 0

    // common fields for all types
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
    var color             : Int64             = 0

    // applicable for type == .transaction
    var lastUpdatedTime   : DateTimeString    = DateTimeString("")
    var deletedTime       : DateTimeString    = DateTimeString("")

    // applicable for type == .scheduled
    var dueDate           : DateString        = DateString("")
    var repeatAuto        : RepeatAuto        = .defaultValue
    var repeatType        : RepeatType        = .defaultValue
    var repeatNum         : Int               = 0

    var splits: [JournalSplitData] = []
}

extension JournalData {
    init(_ data: TransactionData) {
        self.type              = .transaction
        self.transactionId     = data.id
        self.accountId         = data.accountId
        self.toAccountId       = data.toAccountId
        self.payeeId           = data.payeeId
        self.transCode         = data.transCode
        self.transAmount       = data.transAmount
        self.status            = data.status
        self.transactionNumber = data.transactionNumber
        self.notes             = data.notes
        self.categId           = data.categId
        self.transDate         = data.transDate
        self.followUpId        = data.followUpId
        self.toTransAmount     = data.toTransAmount
        self.color             = data.color
        self.lastUpdatedTime   = data.lastUpdatedTime
        self.deletedTime       = data.deletedTime

        self.splits = data.splits.map { split in
            JournalSplitData(
                id: split.id,
                categId: split.categId,
                amount: split.amount,
                notes: split.notes
            )
        }
    }

    init(_ data: ScheduledData, sequence: Int, at transDate: DateTimeString) {
        self.type              = .future
        self.scheduledId       = data.id
        self.sequence          = sequence
        self.accountId         = data.accountId
        self.toAccountId       = data.toAccountId
        self.payeeId           = data.payeeId
        self.transCode         = data.transCode
        self.transAmount       = data.transAmount
        self.status            = data.status
        self.transactionNumber = data.transactionNumber
        self.notes             = data.notes
        self.categId           = data.categId
        self.transDate         = transDate
        self.followUpId        = data.followUpId
        self.toTransAmount     = data.toTransAmount
        self.color             = data.color

        self.splits = data.splits.map { split in
            JournalSplitData(
                id: split.id,
                categId: split.categId,
                amount: split.amount,
                notes: split.notes
            )
        }
    }

    init(_ data: ScheduledData) {
        self.type              = .scheduled
        self.scheduledId       = data.id
        self.accountId         = data.accountId
        self.toAccountId       = data.toAccountId
        self.payeeId           = data.payeeId
        self.transCode         = data.transCode
        self.transAmount       = data.transAmount
        self.status            = data.status
        self.transactionNumber = data.transactionNumber
        self.notes             = data.notes
        self.categId           = data.categId
        self.transDate         = data.transDate
        self.followUpId        = data.followUpId
        self.toTransAmount     = data.toTransAmount
        self.color             = data.color
        self.dueDate           = data.dueDate
        self.repeatAuto        = data.repeatAuto
        self.repeatType        = data.repeatType
        self.repeatNum         = data.repeatNum

        self.splits = data.splits.map { split in
            JournalSplitData(
                id: split.id,
                categId: split.categId,
                amount: split.amount,
                notes: split.notes
            )
        }
    }
}

extension JournalData {
    var toTransaction: TransactionData? {
        type == .transaction || type == .future ? TransactionData(
            id                : transactionId,
            accountId         : accountId,
            toAccountId       : toAccountId,
            payeeId           : payeeId,
            transCode         : transCode,
            transAmount       : transAmount,
            status            : status,
            transactionNumber : transactionNumber,
            notes             : notes,
            categId           : categId,
            transDate         : transDate,
            lastUpdatedTime   : lastUpdatedTime,
            deletedTime       : deletedTime,
            followUpId        : followUpId,
            toTransAmount     : toTransAmount,
            color             : color,
            splits: splits.map { split in
                TransactionSplitData(
                    id: split.id,
                    transId: transactionId, // note: transId would be override
                    categId: split.categId,
                    amount: split.amount,
                    notes: split.notes
                )
            },
        ) : nil
    }

    var toScheduled: ScheduledData? {
        type == .scheduled ? ScheduledData(
            id                : scheduledId,
            accountId         : accountId,
            toAccountId       : toAccountId,
            payeeId           : payeeId,
            transCode         : transCode,
            transAmount       : transAmount,
            status            : status,
            transactionNumber : transactionNumber,
            notes             : notes,
            categId           : categId,
            transDate         : transDate,
            followUpId        : followUpId,
            toTransAmount     : toTransAmount,
            dueDate           : dueDate,
            repeatAuto        : repeatAuto,
            repeatType        : repeatType,
            repeatNum         : repeatNum,
            color             : color,
            splits: splits.map { split in
                ScheduledSplitData(
                    id: split.id,
                    schedId: scheduledId, // note: schedId would be override
                    categId: split.categId,
                    amount: split.amount,
                    notes: split.notes
                )
            },
        ) : nil
    }
    
    var isValid: Bool {
        guard [.withdrawal, .deposit, .transfer].contains(transCode) else { return false }

        if transCode == .transfer {
            guard !toAccountId.isVoid, toAccountId != accountId else { return false }
        } else {
            guard !payeeId.isVoid else { return false }
        }
        guard transAmount >= 0 else { return false }

        if !categId.isVoid {
            return splits.isEmpty
        } else {
            guard splits.count >= 2 else { return false }
            let totalSplit = splits.reduce(0) { $0 + $1.amount }
            let absTotal = abs(totalSplit)
            return abs(absTotal - transAmount) < 0.000001
        }
    }

    var id: DataId {
        return type == .transaction ? transactionId: scheduledId
    }
    
    var actual: Double {
        return switch transCode {
        case .withdrawal: 0 - transAmount;
        case .deposit: transAmount;
        default: 0.0
        }
    }
}

extension JournalData {
    static func newTransaction() -> JournalData {
        JournalData(
            type: .transaction,
            transDate: DateTimeString(Date())
        )
    }

    static func newScheduled() -> JournalData {
        JournalData(
            type: .scheduled,
            transDate: DateTimeString(Date()),
            dueDate: DateString(Date()),
            repeatAuto: .none,
            repeatType: .once,
            repeatNum: 0
        )
    }
}


// 扩展 JournalData 数组 → TransactionData 数组
extension Array where Element == JournalData {
    func asTransactions() -> [TransactionData] {
        compactMap { $0.toTransaction } // 只取成功转换的（type == .transaction/.future）
    }
}

// 扩展 TransactionData 数组 → JournalData 数组
extension Array where Element == TransactionData {
    func asJournals() -> [JournalData] {
        map { JournalData($0) }
    }
}
