//
//  ScheduledSplitData.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct ScheduledSplitData: DataProtocol {
    var id      : DataId = .void
    var schedId : DataId = .void
    var categId : DataId = .void
    var amount  : Double = 0.0
    var notes   : String = ""
}

extension ScheduledSplitData {
    static let dataName = ("Scheduled Transaction Split", "Scheduled Transaction Splits")

    func shortDesc() -> String {
        "#\(self.id.value)"
    }

    mutating func copy() {
        id = .void
    }

    mutating func resolveConstraint(conflictingWith existing: ScheduledSplitData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

extension ScheduledSplitData {
    static let sampleData: [ScheduledSplitData] = [
    ]
}
