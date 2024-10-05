//
//  ScheduledSplit.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct ScheduledSplitData: ExportableEntity {
    var id      : Int64  = 0
    var schedId : Int64  = 0
    var categId : Int64  = 0
    var amount  : Double = 0.0
    var notes   : String = ""
}

extension ScheduledSplitData: DataProtocol {
    static let dataName = "ScheduledSplit"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension ScheduledSplitData {
    static let sampleData: [ScheduledSplitData] = [
    ]
}
