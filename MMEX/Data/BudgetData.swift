//
//  BudgetData.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum BudgetFrequency: String, ChoiceProtocol {
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
    
    var suffix: String {
        switch self {
        case .none       : " (N/A)"
        case .weekly     : " / week"
        case .biweekly   : " / 2 weeks"
        case .monthly    : " / month"
        case .bimonthly  : " / 2 months"
        case .quarterly  : " / 3 months"
        case .halfyearly : " / 6 months"
        case .yearly     : " / year"
        case .daily      : " / day"
        }
    }
}

struct BudgetData: DataProtocol {
    var id         : DataId          = .void
    var periodId   : DataId          = .void
    var categoryId : DataId          = .void
    var frequency  : BudgetFrequency = .defaultValue
    var flow       : Double          = 0.0
    var notes      : String          = ""
    var active     : Bool            = false
}

extension BudgetData {
    static let dataName = ("Budget", "Budgets")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }
}

extension BudgetData {
    static let sampleData: [BudgetData] = [
        BudgetData(
            id: 1, periodId: 1, categoryId: 1, frequency: .halfyearly,
            flow: -20, active: true
        ),
        BudgetData(
            id: 2, periodId: 1, categoryId: 2, frequency: .monthly,
            flow: -10, active: true
        ),
    ]
}
