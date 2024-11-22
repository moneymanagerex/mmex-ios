//
//  BudgetData.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum BudgetFrequency: String, EnumCollateNoCase {
    case none       = "None"
    case weekly     = "Weekly"
    case biweekly   = "Fortnightly"
    case monthly    = "Monthly"
    case bimonthly  = "Every 2 Months"
    case quarterly  = "Quarterly"
    case halfyearly = "Half-Yearly"
    case yearly     = "Yearly"
    case daily      = "Daily"
    static let defaultValue = Self.none

    var timesPerYear: Int {
        switch self {
        case .none       : 0
        case .weekly     : 52
        case .biweekly   : 26
        case .monthly    : 12
        case .bimonthly  : 6
        case .quarterly  : 4
        case .halfyearly : 2
        case .yearly     : 1
        case .daily      : 365
        }
    }
}

struct BudgetData: ExportableEntity {
    var id        : DataId          = .void
    var periodId  : DataId          = .void
    var categId   : DataId          = .void
    var frequency : BudgetFrequency = .defaultValue
    var amount    : Double          = 0.0
    var notes     : String          = ""
    var active    : Bool            = false
}

extension BudgetData: DataProtocol {
    static let dataName = ("Budget", "Budget")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }
}

extension BudgetData {
    static let sampleData: [BudgetData] = [
    ]
}
