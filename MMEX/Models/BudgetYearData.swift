//
//  BudgetYear.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct BudgetYearData: ExportableEntity {
    var id   : Int64  = 0
    var name : String = ""
}

extension BudgetYearData: DataProtocol {
    static let dataName = "BudgetYear"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension BudgetYearData {
    static let sampleData: [BudgetYearData] = [
    ]
}
