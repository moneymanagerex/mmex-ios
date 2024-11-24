//
//  InfotableData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

enum InfoKey: String {
    case baseCurrencyID   = "BASECURRENCYID"
    case categDelimiter   = "CATEG_DELIMITER"
    case createDate       = "CREATEDATE"
    case dateFormat       = "DATEFORMAT"
    case defaultAccountID = "DEFAULTACCOUNTID"
    case uid              = "UID"
    case userName         = "USERNAME"

    var id: String { return rawValue }
}

struct InfotableData: DataProtocol {
    var id    : DataId = .void
    var name  : String = ""
    var value : String = ""

    // unique(name)
}

extension InfotableData {
    static let dataName = ("Infotable", "Infotable")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
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
