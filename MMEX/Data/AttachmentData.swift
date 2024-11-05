//
//  AttachmentData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum RefType: String, EnumCollateNoCase {
    case transaction      = "Transaction"
    case stock            = "Stock"
    case asset            = "Asset"
    case account          = "BankAccount"
    case scheduled        = "RecurringTransaction"
    case payee            = "Payee"
    case transactionSplit = "TransactionSplit"
    case scheduledSplit   = "RecurringTransactionSplit"
    static let defaultValue = Self.transaction
}

struct AttachmentData: ExportableEntity {
    var id          : DataId  = .void
    var refType     : RefType = .defaultValue
    var refId       : DataId  = .void
    var description : String  = ""
    var filename    : String  = ""
}

extension AttachmentData: DataProtocol {
    static let dataName = ("Attachment", "Attachments")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }
}

extension AttachmentData {
    static let sampleData: [AttachmentData] = [
    ]
}
