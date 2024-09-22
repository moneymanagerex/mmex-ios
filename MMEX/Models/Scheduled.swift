//
//  Scheduled.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import SQLite
import Foundation

struct Scheduled: ExportableEntity {
    var id                 : Int64
    var accountId          : Int64
    var toAccountId        : Int64
    var payeeId            : Int64
    var transCode          : Transcode
    var transAmount        : Double
    var status             : TransactionStatus
    var transactionNumber  : String
    var notes              : String
    var categId            : Int64
    var transDate          : String
    var followUpId         : Int64
    var toTransAmount      : Double
    var repeats            : Int
    var nextOccurrenceDate : String
    var numOccurrences     : Int
    var color              : Int64

    init(
        id                 : Int64             = 0,
        accountId          : Int64             = 0,
        toAccountId        : Int64             = 0,
        payeeId            : Int64             = 0,
        transCode          : Transcode         = Transcode.withdrawal,
        transAmount        : Double            = 0.0,
        status             : TransactionStatus = TransactionStatus.none,
        transactionNumber  : String            = "",
        notes              : String            = "",
        categId            : Int64             = 0,
        transDate          : String            = "",
        followUpId         : Int64             = 0,
        toTransAmount      : Double            = 0.0,
        repeats            : Int               = 0,
        nextOccurrenceDate : String            = "",
        numOccurrences     : Int               = 0,
        color              : Int64             = 0
    ) {
        self.id                 = id
        self.accountId          = accountId
        self.toAccountId        = toAccountId
        self.payeeId            = payeeId
        self.transCode          = transCode
        self.transAmount        = transAmount
        self.status             = status
        self.transactionNumber  = transactionNumber
        self.notes              = notes
        self.categId            = categId
        self.transDate          = transDate
        self.followUpId         = followUpId
        self.toTransAmount      = toTransAmount
        self.repeats            = repeats
        self.nextOccurrenceDate = nextOccurrenceDate
        self.numOccurrences     = numOccurrences
        self.color              = color
    }
}

extension Scheduled: ModelProtocol {
    static let modelName = "Scheduled"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension Scheduled {
    static let sampleData : [Scheduled] = [
        Scheduled(
            id: 1, accountId: 1, payeeId: 1, transCode: Transcode.withdrawal,
            transAmount: 10.01, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        Scheduled(
            id: 2, accountId: 2, payeeId: 2, transCode: Transcode.deposit,
            transAmount: 20.02, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        Scheduled(
            id: 3, accountId: 3, payeeId: 3, transCode: Transcode.transfer,
            transAmount: 30.03, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
    ]
}
