//
//  Field.swift
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

struct FieldData: ExportableEntity {
    var id          : Int64     = 0
    var refType     : RefType   = RefType.defaultValue
    var description : String    = ""
    var type        : FieldType = FieldType.defaultValue
    var properties  : String  = ""
    static let refTypes: Set<RefType> = [ .transaction, .scheduled ]
}

extension FieldData: DataProtocol {
    static let dataName = "Field"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension FieldData {
    static let sampleData: [FieldData] = [
    ]
}
