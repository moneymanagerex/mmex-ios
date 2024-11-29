//
//  AssetData.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum AssetType: String, ChoiceProtocol {
    case property   = "Property"
    case automobile = "Automobile"
    case household  = "Household Object"
    case art        = "Art"
    case jewellery  = "Jewellery"
    case cash       = "Cash"
    case other      = "Other"
    static let defaultValue = Self.property
}

enum AssetStatus: String, ChoiceProtocol {
    case closed = "Closed"
    case open   = "Open"
    static let defaultValue = Self.open

    var isOpen: Bool {
        get { self == .open }
        set { self = newValue ? .open : .closed }
    }
}

enum AssetChange: String, ChoiceProtocol {
    case none        = "None"
    case appreciates = "Appreciates"
    case depreciates = "Depreciates"
    static let defaultValue = Self.none
}

enum AssetChangeMode: String, ChoiceProtocol {
    case percentage = "Percentage"
    case linear     = "Linear"
    static let defaultValue = Self.percentage
}

struct AssetData: DataProtocol {
    var id         : DataId           = .void
    var type       : AssetType        = .defaultValue
    var status     : AssetStatus      = .defaultValue
    var name       : String           = ""
    var startDate  : DateString       = DateString("")
    var currencyId : DataId           = .void
    var value      : Double           = 0.0
    var change     : AssetChange      = .defaultValue
    var changeMode : AssetChangeMode  = .defaultValue
    var changeRate : Double           = 0.0
    var notes      : String           = ""
}

extension AssetData {
    static let dataName = ("Asset", "Assets")

    func shortDesc() -> String {
        "#\(self.id.value): \(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }
}

extension AssetData {
    static let sampleData: [AssetData] = [
        AssetData(
            id: 1, type: AssetType.property, status: AssetStatus.open, name: "House",
            startDate: DateString("2010-01-01"), currencyId: 1, value: 100_000.0,
            change: AssetChange.none, notes: "Address"
        ),
        AssetData(
            id: 2, type: AssetType.automobile, status: AssetStatus.open, name: "Car",
            startDate: DateString("2020-01-01"), currencyId: 1, value: 10_000.0,
            change: AssetChange.depreciates,
            changeMode: AssetChangeMode.percentage, changeRate: 5.0
        ),
    ]
}
