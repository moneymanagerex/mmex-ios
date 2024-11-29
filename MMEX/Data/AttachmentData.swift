//
//  AttachmentData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum RefType: String, ChoiceProtocol {
    case transaction      = "Transaction"
    case stock            = "Stock"
    case asset            = "Asset"
    case account          = "BankAccount"
    case scheduled        = "RecurringTransaction"
    case payee            = "Payee"
    case transactionSplit = "TransactionSplit"
    case scheduledSplit   = "RecurringTransactionSplit"
    static let defaultValue = Self.transaction

    var name: String {
        switch self {
        case .account          : "Account"
        case .transactionSplit : "Transaction Split"
        case .scheduled        : "Scheduled"
        case .scheduledSplit   : "Scheduled Split"
        default: rawValue
        }
    }
}

struct AttachmentData: DataProtocol {
    var id          : DataId  = .void
    var refType     : RefType = .defaultValue
    var refId       : DataId  = .void
    var description : String  = ""
    var filename    : String  = ""
}

extension AttachmentData {
    static let dataName = ("Attachment", "Attachments")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }
}

extension AttachmentData {
    static let sampleData: [AttachmentData] = [
        AttachmentData(
            id: 1, refType: .account, refId: 1,
            description: "Document A", filename: "info_A.txt"
        ),
        AttachmentData(
            id: 2, refType: .transaction, refId: 1,
            description: "Invoice", filename: "invoice_A.pdf"
        ),
    ]
}
