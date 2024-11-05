//
//  BudgetData.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum BudgetPeriod: String, EnumCollateNoCase {
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
}

struct BudgetData: ExportableEntity {
    var id      : DataId       = .void
    var yearId  : DataId       = .void
    var categId : DataId       = .void
    var period  : BudgetPeriod = .defaultValue
    var amount  : Double       = 0.0
    var notes   : String       = ""
    var active  : Bool         = false
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
