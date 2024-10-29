//
//  BudgetTable.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
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

struct BudgetTableData: ExportableEntity {
    var id      : DataId       = .void
    var yearId  : DataId       = .void
    var categId : DataId       = .void
    var period  : BudgetPeriod = BudgetPeriod.defaultValue
    var amount  : Double       = 0.0
    var notes   : String       = ""
    var active  : Bool         = false
}

extension BudgetTableData: DataProtocol {
    static let dataName = ("Budget Table", "Budget Tables")

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension BudgetTableData {
    static let sampleData: [BudgetTableData] = [
    ]
}
