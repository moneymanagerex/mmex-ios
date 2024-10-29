//
//  BudgetYear.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetYearData: ExportableEntity {
    var id   : DataId = .void
    var name : String = ""
}

extension BudgetYearData: DataProtocol {
    static let dataName = ("Budget Year", "Budget Years")

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension BudgetYearData {
    static let sampleData: [BudgetYearData] = [
    ]
}
