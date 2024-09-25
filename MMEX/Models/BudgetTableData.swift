//
//  BudgetTable.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum Period: String, EnumCollateNoCase {
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
    var id      : Int64  = 0
    var yearId  : Int64  = 0
    var categId : Int64  = 0
    var period  : Period = Period.defaultValue
    var amount  : Double = 0.0
    var notes   : String = ""
    var active  : Bool   = false
}

extension BudgetTableData: DataProtocol {
    static let dataName = "BudgetTable"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension BudgetTableData {
    static let sampleData: [BudgetTableData] = [
    ]
}
