//
//  Account.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import Foundation
import SQLite

enum AccountStatus: String, EnumCollateNoCase {
    case open   = "Open"
    case closed = "Closed"
    static let defaultValue = Self.closed
}

enum AccountType: String, EnumCollateNoCase {
    case cash       = "Cash"
    case checking   = "Checking"
    case creditCard = "Credit Card"
    case loan       = "Loan"
    case term       = "Term"
    case investment = "Investment"
    case asset      = "Asset"
    case shares     = "Shares"
    static let defaultValue = Self.checking
}

struct AccountData: ExportableEntity {
    var id              : Int64
    var name            : String
    var type            : AccountType
    var num             : String
    var status          : AccountStatus
    var notes           : String
    var heldAt          : String
    var website         : String
    var contactInfo     : String
    var accessInfo      : String
    var initialDate     : String
    var initialBal      : Double
    var favoriteAcct    : String
    var currencyId      : Int64
    var statementLocked : Bool
    var statementDate   : String
    var minimumBalance  : Double
    var creditLimit     : Double
    var interestRate    : Double
    var paymentDueDate  : String
    var minimumPayment  : Double

    init(
        id              : Int64         = 0,
        name            : String        = "",
        type            : AccountType   = AccountType.defaultValue,
        num             : String        = "",
        status          : AccountStatus = AccountStatus.defaultValue,
        notes           : String        = "",
        heldAt          : String        = "",
        website         : String        = "",
        contactInfo     : String        = "",
        accessInfo      : String        = "",
        initialDate     : String        = "",
        initialBal      : Double        = 0.0,
        favoriteAcct    : String        = "",
        currencyId      : Int64         = 0,
        statementLocked : Bool          = false,
        statementDate   : String        = "",
        minimumBalance  : Double        = 0.0,
        creditLimit     : Double        = 0.0,
        interestRate    : Double        = 0.0,
        paymentDueDate  : String        = "",
        minimumPayment  : Double        = 0.0
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
    }
}

extension AccountData: DataProtocol {
    static let modelName = "Account"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

struct AccountFull: ExportableEntity, FullProtocol {
    var data: AccountData
    var currency: CurrencyData?
    var id: Int64 { data.id }
    init(data: AccountData = AccountData(), currency: CurrencyData? = nil) {
        self.data     = data
        self.currency = currency
    }
}

extension AccountData {
    static let accountTypeToSFSymbol: [String: String] = [
        "Cash"        : "dollarsign.circle.fill",
        "Checking"    : "banknote.fill",
        "Credit Card" : "creditcard.fill",
        "Loan"        : "building.columns.fill",
        "Term"        : "calendar.circle.fill",
    ]
}

extension AccountData {
    static let sampleData : [AccountData] = [
        AccountData(
            id: 1, name: "Account A", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 1
        ),
        AccountData(
            id: 2, name: "Account B", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ),
        AccountData(
            id: 3, name: "Investment Account", type: AccountType.investment,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ),
    ]
}

extension AccountFull {
    static let sampleFull : [AccountFull] = [
        AccountFull(data:AccountData(
            id: 1, name: "Account A", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 1
        ), currency: CurrencyData.sampleData[0]),
        AccountFull(data:AccountData(
            id: 2, name: "Account B", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ), currency: CurrencyData.sampleData[1]),
        AccountFull(data:AccountData(
            id: 3, name: "Investment Account", type: AccountType.investment,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ), currency: CurrencyData.sampleData[1]),
    ]
}
