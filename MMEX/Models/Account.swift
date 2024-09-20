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
    case cash       = "Cash"
    case checking   = "Checking"
    case creditCard = "Credit Card"
    case loan       = "Loan"
    case term       = "Term"
    case investment = "Investment"
    case asset      = "Asset"
    case shares     = "Shares"

    var id: String { self.rawValue }
    var name: String {
        rawValue.capitalized
    }
}

struct Account: ExportableEntity {
    var id: Int64               // ACCOUNTID INTEGER PRIMARY KEY
    var name: String            // ACCOUNTNAME TEXT COLLATE NOCASE NOT NULL UNIQUE
    var type: AccountType       // ACCOUNTTYPE TEXT NOT NULL (Cash, Checking, ...)
    var num: String?            // ACCOUNTNUM TEXT
    var status: AccountStatus   // STATUS TEXT NOT NULL (Open, Closed)
    var notes: String?          // NOTES TEXT
    var heldAt: String?         // HELDAT TEXT
    var website: String?        // WEBSITE TEXT
    var contactInfo: String?    // CONTACTINFO TEXT
    var accessInfo: String?     // ACCESSINFO TEXT
    var initialDate: String?    // INITIALDATE TEXT
    var initialBal: Double?     // INITIALBAL NUMERIC
    var favoriteAcct: String    // FAVORITEACCT NOT NULL TEXT
    var currencyId: Int64       // CURRENCYID NOT NULL INTEGER
    var statementLocked: Bool?  // STATEMENTLOCKED INTEGER
    var statementDate: String?  // STATEMENTDATE TEXT
    var minimumBalance: Double? // MINIMUMBALANCE NUMERIC
    var creditLimit: Double?    // CREDITLIMIT NUMERIC
    var interestRate: Double?   // INTERESTRATE NUMERIC
    var paymentDueDate: String? // PAYMENTDUEDATE TEXT
    var minimumPayment: Double? // MINIMUMPAYMENT NUMERIC

    var currency: Currency?

    init(
        id: Int64, name: String, type: AccountType,
        num: String? = nil, status: AccountStatus, notes: String? = nil,
        heldAt: String? = nil, website: String? = nil, contactInfo: String? = nil,
        accessInfo: String? = nil, initialDate: String? = nil, initialBal: Double? = nil,
        favoriteAcct: String, currencyId: Int64, statementLocked: Bool? = nil,
        statementDate: String? = nil, minimumBalance: Double? = nil, creditLimit: Double? = nil,
        interestRate: Double? = nil, paymentDueDate: String? = nil, minimumPayment: Double? = nil,
        currency: Currency? = nil
    ) {
        self.id              = id
        self.name            = name
        self.type            = type
        self.num             = num
        self.status          = status
        self.notes           = notes
        self.heldAt          = heldAt
        self.website         = website
        self.contactInfo     = contactInfo
        self.accessInfo      = accessInfo
        self.initialDate     = initialDate
        self.initialBal      = initialBal
        self.favoriteAcct    = favoriteAcct
        self.currencyId      = currencyId
        self.statementLocked = statementLocked
        self.statementDate   = statementDate
        self.minimumBalance  = minimumBalance
        self.creditLimit     = creditLimit
        self.interestRate    = interestRate
        self.paymentDueDate  = paymentDueDate
        self.minimumPayment  = minimumPayment
        self.currency        = currency
    }
}

extension Account {
    static var empty: Account { Account(
        id: 0, name: "", type: AccountType.cash, status: AccountStatus.open, notes: "",
        initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 0
    ) }
}

extension Account {
    static let sampleData : [Account] = [
        Account(
            id: 1, name: "Account A", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 1,
            currency: Currency.sampleData[0]
        ),
        Account(
            id: 2, name: "Account B", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2,
            currency: Currency.sampleData[1]
        ),
    ]
}

extension Account {
    static let accountTypeToSFSymbol: [String: String] = [
        "Cash"        : "dollarsign.circle.fill",
        "Checking"    : "banknote.fill",
        "Credit Card" : "creditcard.fill",
        "Loan"        : "building.columns.fill",
        "Term"        : "calendar.circle.fill",
    ]
}
