//
//  TagLinkData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagLinkData: ExportableEntity {
    var id      : Int64   = 0
    var tagId   : Int64   = 0
    var refType : RefType = RefType.transaction
    var refId   : Int64   = 0
    static let refTypes: Set<RefType> = [
        .transaction, .transactionSplit,
        .scheduled, .scheduledSplit,
    ]
}

extension TagLinkData: DataProtocol {
    static let dataName = "TagLink"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension TagLinkData {
    static let sampleData: [TagLinkData] = [
    ]
}
