//
//  Account.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import Foundation
import SQLite

enum AccountStatus: String, CaseIterable, Identifiable, Codable {
    case open = "Open"
    case closed = "Closed"
    
    var id: String { self.rawValue }
    var name: String {
        rawValue.capitalized
    }
}

enum AccountType: String, CaseIterable, Identifiable, Codable {
    case cash = "Cash"
    case checking = "Checking"
    case creditCard = "Credit Card"
    case loan = "Loan"
    case term = "Term"
    case investment = "Investment"
    case asset = "Asset"
    case shares = "Shares"

    var id: String { self.rawValue }
    var name: String {
        rawValue.capitalized
    }
}

struct Account: ExportableEntity {
    var id: Int64
    var name: String
    var type: AccountType
    var status: AccountStatus
    var favoriteAcct: String
    var currencyId: Int64
    var balance: Double?
    var notes: String?
    var currency: Currency?
    
    init(id: Int64, name: String, type: AccountType, status: AccountStatus, favoriteAcct: String, currencyId: Int64, balance: Double? = nil, notes: String? = nil, currency: Currency? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.status = status
        self.favoriteAcct = favoriteAcct
        self.currencyId = currencyId
        self.balance = balance
        self.notes = notes
        self.currency = currency
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
        Account(id: 0, name: "", type: AccountType.cash, status: AccountStatus.open, favoriteAcct: "TRUE", currencyId: 0, balance: 0.0, notes: "")
    }
}
extension Account {
    static let sampleData : [Account] = 
    [
        Account(id: 1, name: "Account A", type: AccountType.cash, status: AccountStatus.open, favoriteAcct: "TRUE", currencyId: 1, balance:0.0, notes:"", currency: Currency.sampleData[0]),
        Account(id: 2, name: "Account B", type: AccountType.cash, status: AccountStatus.open, favoriteAcct: "TRUE", currencyId: 2, balance:0.0, notes:"", currency: Currency.sampleData[1])
    ]
}

extension Account {
    static func fromRow(_ row: Row) -> Account {
        return Account(id: row[Account.accountID],
                       name: row[Account.accountName],
                       type: AccountType(rawValue: row[Account.accountType]) ?? AccountType.cash,
                       status: AccountStatus(rawValue: row[Account.status]) ?? AccountStatus.open,
                       favoriteAcct: row[Account.favoriteAcct],
                       currencyId: row[Account.currencyID],
                       balance: row[Account.balance],
                       notes: row[Account.notes]
        )
    }

    static func getSetters(_ account: Account) -> [Setter] {
        return  [Account.accountName <- account.name,
                 Account.accountType <- account.type.id,
                 Account.status <- account.status.id,
                 Account.favoriteAcct <- account.favoriteAcct,
                 Account.currencyID <- account.currencyId,
                 Account.balance <- account.balance,
                 Account.notes <- account.notes
                 ]
    }
}

extension Account {
    static let accountTypeToSFSymbol: [String: String] = [
        "Cash": "dollarsign.circle.fill",
        "Checking": "banknote.fill",
        "Credit Card": "creditcard.fill",
        "Loan": "building.columns.fill",
        "Term": "calendar.circle.fill"
    ]
}
