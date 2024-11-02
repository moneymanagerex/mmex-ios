//
//  TagLinkData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagLinkData: ExportableEntity {
    var id      : DataId  = .void
    var tagId   : DataId  = .void
    var refType : RefType = RefType.transaction
    var refId   : DataId  = .void
    static let refTypes: Set<RefType> = [
        .transaction, .transactionSplit,
        .scheduled, .scheduledSplit,
    ]
}

extension TagLinkData: DataProtocol {
    static let dataName = ("Tag Link", "Tag Links")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }
}

extension TagLinkData {
    static let sampleData: [TagLinkData] = [
    ]
}
