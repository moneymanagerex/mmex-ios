//
//  TagLinkData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagLinkData: DataProtocol {
    var id      : DataId  = .void
    var tagId   : DataId  = .void
    var refType : RefType = .transaction
    var refId   : DataId  = .void

    // unique(refType, refId, tagId)

    static let refTypes: Set<RefType> = [
        .transaction, .transactionSplit,
        .scheduled, .scheduledSplit,
    ]
}

extension TagLinkData {
    static let dataName = ("Tag Link", "Tag Links")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: TagLinkData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension TagLinkData {
    static let sampleData: [TagLinkData] = [
    ]
}
