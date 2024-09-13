//
//  Payee.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct Payee: Identifiable {
    var id: Int64
    var name: String
    var categoryId: Int64?
    var number: String?
    var website: String?
    var notes: String?
    var active: Int
    var pattern: String
    var category: Category?
    
    init(id: Int64, name: String, categoryId: Int64? = nil, number: String? = nil, website: String? = nil, notes: String? = nil, active: Int = 1, pattern: String = "") {
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
    static let sampleData: [Payee] =
    [
        Payee(id: 1, name: "Payee A", categoryId: 1, number: "123456", website: "www.payeeA.com", notes: "Frequent payee"),
        Payee(id: 2, name: "Payee B", categoryId: 2, number: "654321", website: "www.payeeB.com", notes: "Rare payee", active: 0)
    ]
}

extension Payee {
    static var empty: Payee { Payee(id: 0, name: "") }
    
    static let table = Table("PAYEE_V1")
    
    static let payeeID = Expression<Int64>("PAYEEID")
    static let payeeName = Expression<String>("PAYEENAME")
    static let categoryID = Expression<Int64?>("CATEGID")
    static let number = Expression<String?>("NUMBER")
    static let website = Expression<String?>("WEBSITE")
    static let notes = Expression<String?>("NOTES")
    static let active = Expression<Int?>("ACTIVE")
    static let pattern = Expression<String>("PATTERN")
}
