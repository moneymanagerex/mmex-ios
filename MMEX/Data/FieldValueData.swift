//
//  FieldValueData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct FieldValueData: ExportableEntity {
    var id      : DataId  = .void
    var fieldId : DataId  = .void
    var refType : RefType = .transaction
    var refId   : DataId  = .void
    var content : String  = ""

    // unique(fieldId, refType, refId)

    static let refTypes: Set<RefType> = [ .transaction, .scheduled ]
}

extension FieldValueData: DataProtocol {
    static let dataName = ("Custom Field Value", "Custom Field Values")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: FieldValueData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension FieldValueData {
    static let sampleData: [FieldValueData] = [
        FieldValueData(
            id: 1, fieldId: 1, refType: .transaction, refId: 1, content: "1"
        ),
        FieldValueData(
            id: 2, fieldId: 2, refType: .scheduled, refId: 1, content: "info"
        ),
    ]
}
