//
//  FieldData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum FieldType: String, EnumCollateNoCase {
    case string       = "String"
    case integer      = "Integer"
    case decimal      = "Decimal"
    case boolean      = "Boolean"
    case date         = "Date"
    case time         = "Time"
    case singleChoice = "SingleChoice"
    case multiChoice  = "MultiChoice"
    case unknown      = ""
    static let defaultValue = Self.unknown
}

struct FieldData: DataProtocol {
    var id          : DataId    = .void
    var refType     : RefType   = .defaultValue
    var description : String    = ""
    var type        : FieldType = .defaultValue
    var properties  : String    = ""

    static let refTypes: Set<RefType> = [ .transaction, .scheduled ]
}

extension FieldData {
    static let dataName = ("Custom Field", "Custom Fields")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }
}

extension FieldData {
    static let sampleData: [FieldData] = [
        FieldData(
            id: 1, refType: .transaction, description: "field 1", type: .integer
        ),
        FieldData(
            id: 2, refType: .scheduled, description: "field 2", type: .string
        ),
    ]
}
