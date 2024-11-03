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

struct JournalData {
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
    var transCode         : TransactionType   = TransactionType.defaultValue
    var transAmount       : Double            = 0.0
    var status            : TransactionStatus = TransactionStatus.defaultValue
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
    var repeatAuto        : RepeatAuto        = RepeatAuto.defaultValue
    var repeatType        : RepeatType        = RepeatType.defaultValue
    var repeatNum         : Int               = 0
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
            color             : color
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
            color             : color
        ) : nil
    }
}
