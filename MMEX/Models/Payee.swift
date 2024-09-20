//
//  Payee.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct Payee: ExportableEntity {
    var id: Int64          // PAYEEID INTEGER PRIMARY KEY
    var name: String       // PAYEENAME TEXT COLLATE NOCASE UNIQUE
    var categoryId: Int64? // CATEGID INTEGER
    var number: String?    // NUMBER TEXT
    var website: String?   // WEBSITE TEXT
    var notes: String?     // NOTES TEXT
    var active: Int?       // ACTIVE INTEGER
    var pattern: String    // PATTERN TEXT DEFAULT ''
    
    init(
        id: Int64, name: String, categoryId: Int64? = nil, number: String? = nil,
        website: String? = nil, notes: String? = nil, active: Int = 1, pattern: String = ""
    ) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.number = number
        self.website = website
        self.notes = notes
        self.active = active
        self.pattern = pattern
    }
}

extension Payee {
    // empty payee
    static var empty: Payee { Payee(id: 0, name: "") }
}

extension Payee {
    static let sampleData: [Payee] = [
        Payee(
            id: 1, name: "Payee A", categoryId: 1, number: "123456",
            website: "www.payeeA.com", notes: "Frequent payee"
        ),
        Payee(
            id: 2, name: "Payee B", categoryId: 2, number: "654321",
            website: "www.payeeB.com", notes: "Rare payee", active: 0
        ),
    ]
}
