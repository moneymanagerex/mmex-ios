//
//  FieldContentData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct FieldContentData: ExportableEntity {
    var id      : DataId  = .void
    var fieldId : DataId  = .void
    var refType : RefType = RefType.transaction
    var refId   : DataId  = .void
    var content : String  = ""
    static let refTypes: Set<RefType> = [ .transaction, .scheduled ]
}

extension FieldContentData: DataProtocol {
    static let dataName = ("Field Content", "Field Contents")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }
}

extension FieldContentData {
    static let sampleData: [FieldContentData] = [
    ]
}
