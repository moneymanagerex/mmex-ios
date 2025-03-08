//
//  TransactionLinkData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

// copy from MMEX4Desktop
enum CHECKING_TYPE: DataId {
    case AS_INCOME_EXPENSE = 32701
    case AS_TRANSFER
}

struct TransactionLinkData: DataProtocol {
    var id      : DataId  = .void
    var transId : DataId  = .void
    var refType : RefType = .asset
    var refId   : DataId  = .void
    static let refTypes: Set<RefType> = [ .asset, .stock ]
}

extension TransactionLinkData {
    static let dataName = ("Transaction Link", "Transaction Links")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: TransactionLinkData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension TransactionLinkData {
    static let sampleData: [TransactionLinkData] = [
        TransactionLinkData (id: 1, transId: 8, refType: .stock, refId: 1),
        TransactionLinkData (id: 2, transId: 10, refType: .stock, refId: 2),
    ]
}
