//
//  Infotable.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

enum InfoKey: String {
    case userName = "USERNAME"
    case baseCurrencyID = "BASECURRENCYID"
    case defaultAccountID = "DEFAULTACCOUNTID"
    case dateFormat = "DATEFORMAT"
    case createDate = "CREATEDATE"
    case uid = "UID"

    var id: String { return rawValue }
}

struct InfotableData: ExportableEntity {
    var id    : Int64  = 0
    var name  : String = ""
    var value : String = ""
}

extension InfotableData: DataProtocol {
    static let dataName = "Infotable"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension InfotableData {
    // Helper method to get value as a specific type
    func getValue<T: LosslessStringConvertible>(_ type: T.Type) -> T? {
        return T(value)
    }

    mutating func setValue<T>(_ newValue: T) {
        // Convert the new value to a string before saving
        if let intValue = newValue as? Int {
            self.value = String(intValue)
        } else if let stringValue = newValue as? String {
            self.value = stringValue
        } else {
            print("Unsupported type")
        }
    }
}

extension InfotableData {
    static let sampleData: [InfotableData] = [
        InfotableData(id: 1, name: "DATAVERSION", value: "3"),
        InfotableData(id: 2, name: InfoKey.createDate.id, value: Date().ISO8601Format()),
        InfotableData(id: 3, name: InfoKey.baseCurrencyID.id, value: "1"),
        InfotableData(id: 4, name: InfoKey.defaultAccountID.id, value: "1")
    ]
}
