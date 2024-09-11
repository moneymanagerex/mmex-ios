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
    var active: Int
    
    init(id: Int64, name: String) {
        self.id = id
        self.name = name
        self.active = 1 // TODO
    }
}

extension Payee {
    static let sampleData : [Payee] =
    [
        Payee(id: 1, name: "Payee A"),
        Payee(id: 2, name: "Payee B")
    ]
}

extension Payee {
    // for CRUD
    static var empty : Payee {Payee(id: 0, name: "")}
    
    // Define the table
    static let table = Table("PAYEE_V1")
    
    // Define the columns as Expressions
    static let payeeID = Expression<Int64>("PAYEEID")
    static let payeeName = Expression<String>("PAYEENAME")
    static let active = Expression<Int?> ("ACTIVE")
}
