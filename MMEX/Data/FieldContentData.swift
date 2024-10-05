//
//  FieldContentData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct FieldContentData: ExportableEntity {
    var id      : Int64   = 0
    var fieldId : Int64   = 0
    var refType : RefType = RefType.transaction
    var refId   : Int64   = 0
    var content : String  = ""
    static let refTypes: Set<RefType> = [ .transaction, .scheduled ]
}

extension FieldContentData: DataProtocol {
    static let dataName = "FieldContent"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension FieldContentData {
    static let sampleData: [FieldContentData] = [
    ]
}
