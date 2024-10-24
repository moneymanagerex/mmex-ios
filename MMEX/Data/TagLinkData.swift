//
//  TagLinkData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagLinkData: ExportableEntity {
    var id      : DataId  = 0
    var tagId   : DataId  = 0
    var refType : RefType = RefType.transaction
    var refId   : DataId  = 0
    static let refTypes: Set<RefType> = [
        .transaction, .transactionSplit,
        .scheduled, .scheduledSplit,
    ]
}

extension TagLinkData: DataProtocol {
    static let dataName = ("Tag Link", "Tag Links")

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension TagLinkData {
    static let sampleData: [TagLinkData] = [
    ]
}
