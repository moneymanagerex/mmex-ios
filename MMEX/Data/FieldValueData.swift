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

    // unique(fieldId, refId)

    static let refTypes: Set<RefType> = [ .transaction, .scheduled ]
}

extension FieldValueData: DataProtocol {
    static let dataName = ("Field Value", "Field Values")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }
}

extension FieldValueData {
    static let sampleData: [FieldValueData] = [
    ]
}
