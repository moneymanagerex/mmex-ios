//
//  InfotableData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

enum InfoKey: String {
    case userName         = "USERNAME"
    case baseCurrencyID   = "BASECURRENCYID"
    case defaultAccountID = "DEFAULTACCOUNTID"
    case dateFormat       = "DATEFORMAT"
    case createDate       = "CREATEDATE"
    case uid              = "UID"
    case categDelimiter   = "CATEG_DELIMITER"

    var id: String { return rawValue }
}

struct InfotableData: ExportableEntity {
    var id    : DataId = .void
    var name  : String = ""
    var value : String = ""
}

extension InfotableData: DataProtocol {
    static let dataName = ("Infotable", "Infotable")

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension InfotableData {
    // Helper method to get value as a specific type
    func getValue<T: LosslessStringConvertible>(as type: T.Type) -> T? {
        return T(value)
    }

    mutating func setValue<T: LosslessStringConvertible>(_ newValue: T) {
        self.value = newValue.description
    }
}

extension InfotableData {
    static let sampleData: [InfotableData] = [
        InfotableData(id: 1, name: "DATAVERSION", value: "3"),
        InfotableData(id: 2, name: InfoKey.createDate.id,       value: DateString(Date()).string),
        InfotableData(id: 3, name: InfoKey.baseCurrencyID.id,   value: "1"),
        InfotableData(id: 4, name: InfoKey.defaultAccountID.id, value: "1"),
        InfotableData(id: 5, name: InfoKey.categDelimiter.id, value: ":"),
        InfotableData(id: 6, name: InfoKey.uid.id, value: String(format: "ios_%@", TimestampString(Date()).string)),
    ]
}
