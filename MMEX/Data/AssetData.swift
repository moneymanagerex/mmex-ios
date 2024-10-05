//
//  Asset.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum AssetType: String, EnumCollateNoCase {
    case property   = "Property"
    case automobile = "Automobile"
    case household  = "Household Object"
    case art        = "Art"
    case jewellery  = "Jewellery"
    case cash       = "Cash"
    case other      = "Other"
    static let defaultValue = Self.property
}

enum AssetStatus: String, EnumCollateNoCase {
    case closed = "Closed"
    case open   = "Open"
    static let defaultValue = Self.open

    var isOpen: Bool {
        get { self == .open }
        set { self = newValue ? .open : .closed }
    }
}

enum AssetChange: String, EnumCollateNoCase {
    case none        = "None"
    case appreciates = "Appreciates"
    case depreciates = "Depreciates"
    static let defaultValue = Self.none
}

enum AssetChangeMode: String, EnumCollateNoCase {
    case percentage = "Percentage"
    case linear     = "Linear"
    static let defaultValue = Self.percentage
}

struct AssetData: ExportableEntity {
    var id         : Int64            = 0
    var type       : AssetType        = AssetType.defaultValue
    var status     : AssetStatus      = AssetStatus.defaultValue
    var name       : String           = ""
    var startDate  : DateString       = DateString("")
    var currencyId : Int64            = 0
    var value      : Double           = 0.0
    var change     : AssetChange      = AssetChange.defaultValue
    var changeMode : AssetChangeMode  = AssetChangeMode.defaultValue
    var changeRate : Double           = 0.0
    var notes      : String           = ""
}

extension AssetData: DataProtocol {
    static let dataName = "Asset"

    func shortDesc() -> String {
        "\(self.name), \(self.id)"
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
