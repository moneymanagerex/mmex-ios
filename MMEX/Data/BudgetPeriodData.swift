//
//  BudgetPeriodData.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetPeriodData: ExportableEntity {
    var id   : DataId = .void
    var name : String = ""
}

extension BudgetPeriodData: DataProtocol {
    static let dataName = ("Budget Period", "Budget Periods")

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension BudgetPeriodData {
    static let sampleData: [BudgetPeriodData] = [
    ]
}
