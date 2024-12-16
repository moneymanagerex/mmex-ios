//
//  TagData.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagData: DataProtocol {
    var id     : DataId = .void
    var name   : String = ""
    var active : Bool   = false
    
    // unique(name)
}

extension TagData {
    static let dataName = ("Tag", "Tags")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }

    mutating func resolveConstraint(conflictingWith existing: TagData? = nil) -> Bool {
        /// TODO column level
        self.name = "\(self.name):\(self.id)"
        return true
    }
}

extension TagData {
    static let sampleData: [TagData] = [
        TagData(
            id: 1, name: "waiting", active: true
        ),
        TagData(
            id: 2, name: "missing", active: true
        ),
    ]
}
