//
//  BudgetPeriodData.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetPeriodData: DataProtocol {
    var id   : DataId = .void
    var name : String = ""
    
    // unique(name)
}

extension BudgetPeriodData {
    static let dataName = ("Budget Period", "Budget Periods")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }

    mutating func resolveConstraint(conflictingWith existing: BudgetPeriodData? = nil) -> Bool {
        /// TODO column level
        self.name = "\(self.name):\(self.id)"
        return true
    }
}

extension BudgetPeriodData {
    static let sampleData: [BudgetPeriodData] = [
        BudgetPeriodData(id: 1, name: "2024"),
        BudgetPeriodData(id: 2, name: "2024-01"),
        BudgetPeriodData(id: 3, name: "2025"),
    ]
}
