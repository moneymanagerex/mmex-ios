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

struct Infotable: ExportableEntity {
    var id: Int64
    var name: String
    var value: String

    init(id: Int64, name: String, value: String) {
        self.id = id
        self.name = name
        self.value = value
    }

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

extension Infotable {
    static let sampleData: [Infotable] =
    [
        Infotable(id: 1, name: "DATAVERSION", value: "3")
    ]
}

extension Infotable {
    static var empty: Infotable { Infotable(id: 0, name: "", value: "") }

    static let table = Table("INFOTABLE_V1")

    static let infoID = Expression<Int64>("INFOID")
    static let infoName = Expression<String>("INFONAME")
    static let infoValue = Expression<String>("INFOVALUE")
}
