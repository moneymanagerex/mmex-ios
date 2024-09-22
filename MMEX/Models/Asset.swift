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
}

enum AssetStatus: String, EnumCollateNoCase {
    case closed = "Closed"
    case open   = "Open"
}

enum AssetChange: String, EnumCollateNoCase {
    case none        = "None"
    case appreciates = "Appreciates"
    case depreciates = "Depreciates"
}

enum AssetChangeMode: String, EnumCollateNoCase {
    case percentage = "Percentage"
    case linear     = "Linear"
}

struct Asset: ExportableEntity {
    var id         : Int64
    var type       : AssetType?
    var status     : AssetStatus?
    var name       : String
    var startDate  : String
    var currencyId : Int64?
    var value      : Double?
    var change     : AssetChange?
    var changeMode : AssetChangeMode?
    var changeRate : Double?
    var notes      : String?

    init(
        id         : Int64            = 0,
        type       : AssetType?       = nil,
        status     : AssetStatus?     = nil,
        name       : String           = "",
        startDate  : String           = "",
        currencyId : Int64?           = nil,
        value      : Double?          = nil,
        change     : AssetChange?     = nil,
        changeMode : AssetChangeMode? = nil,
        changeRate : Double?          = nil,
        notes      : String?          = nil
    ) {
        self.id         = id
        self.type       = type
        self.status     = status
        self.name       = name
        self.startDate  = startDate
        self.currencyId = currencyId
        self.value      = value
        self.change     = change
        self.changeMode = changeMode
        self.changeRate = changeRate
        self.notes      = notes
    }
}

extension Asset {
    static let sampleData: [Asset] = [
        Asset(
            id: 1, type: AssetType.property, status: AssetStatus.open, name: "House",
            startDate: "2010-01-01", currencyId: 1, value: 100_000.0,
            change: AssetChange.none, notes: "Address"
        ),
        Asset(
            id: 2, type: AssetType.automobile, status: AssetStatus.open, name: "Car",
            startDate: "2020-01-01", currencyId: 1, value: 10_000.0,
            change: AssetChange.depreciates,
            changeMode: AssetChangeMode.percentage, changeRate: 5.0
        ),
    ]
}
