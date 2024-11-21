//
//  BudgetYearData.swift
//  MMEX
//
//  2024-09-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct YearData: ExportableEntity {
    var id   : DataId = .void
    var name : String = ""
}

extension YearData: DataProtocol {
    static let dataName = ("Budget Year", "Budget Years")

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension YearData {
    static let sampleData: [YearData] = [
    ]
}
