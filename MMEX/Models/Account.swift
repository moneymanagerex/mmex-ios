//
//  Account.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import Foundation
import SQLite

enum Status: String, CaseIterable, Identifiable {
    case open = "Open"
    case closed = "Closed"
    
    var id: String { self.rawValue }
    var name: String {
        rawValue.capitalized
    }
}

struct Account: Identifiable {
    var id: Int64
    var name: String
    var type: String
    var status: Status
    var favoriteAcct: String
    var currencyId: Int64
    var balance: Double?
    var notes: String?
    
    init(id: Int64, name: String, type: String, status: Status, favoriteAcct: String, currencyId: Int64, balance: Double? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.status = status
        self.favoriteAcct = favoriteAcct
        self.currencyId = currencyId
        self.balance = balance
        self.notes = notes
    }
}

extension Account {
    static let table = Table("ACCOUNTLIST_V1")
    
    static let accountID = Expression<Int64>("ACCOUNTID")
    static let accountName = Expression<String>("ACCOUNTNAME")
    static let accountType = Expression<String>("ACCOUNTTYPE")
    static let status = Expression<String>("STATUS")
    static let favoriteAcct = Expression<String>("FAVORITEACCT")
    static let currencyID = Expression<Int64>("CURRENCYID")
    static let balance = Expression<Double?>("INITIALBAL")
    static let notes = Expression<String?>("NOTES")
    
    static var empty: Account {
        Account(id: 0, name: "", type: "", status: Status.open, favoriteAcct: "TRUE", currencyId: 0, balance: 0.0, notes: "")
    }
}
extension Account {
    static let sampleData : [Account] = 
    [
        Account(id: 1, name: "Account A", type: "Cash", status: Status.open, favoriteAcct: "TRUE", currencyId: 1, balance:0.0, notes:""),
        Account(id: 2, name: "Account B", type: "Cash", status: Status.open, favoriteAcct: "TRUE", currencyId: 1, balance:0.0, notes:"")
    ]
}

