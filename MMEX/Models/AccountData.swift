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
    var id              : Int64         = 0
    var name            : String        = ""
    var type            : AccountType   = AccountType.defaultValue
    var num             : String        = ""
    var status          : AccountStatus = AccountStatus.defaultValue
    var notes           : String        = ""
    var heldAt          : String        = ""
    var website         : String        = ""
    var contactInfo     : String        = ""
    var accessInfo      : String        = ""
    var initialDate     : String        = ""
    var initialBal      : Double        = 0.0
    var favoriteAcct    : String        = ""
    var currencyId      : Int64         = 0
    var statementLocked : Bool          = false
    var statementDate   : String        = ""
    var minimumBalance  : Double        = 0.0
    var creditLimit     : Double        = 0.0
    var interestRate    : Double        = 0.0
    var paymentDueDate  : String        = ""
    var minimumPayment  : Double        = 0.0
}

extension AccountData: DataProtocol {
    static let dataName = "Account"

    func shortDesc() -> String {
        "\(self.name)"
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

// TODO: move to ViewModels
struct AccountWithCurrency: ExportableEntity {
    var data: AccountData = AccountData()
    var currency: CurrencyData?
    var id: Int64 { data.id }
}
extension AccountData {
    static let sampleDataWithCurrency : [AccountWithCurrency] = [
        AccountWithCurrency(data: AccountData(
            id: 1, name: "Account A", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 1
        ), currency: CurrencyData.sampleData[0]),
        AccountWithCurrency(data: AccountData(
            id: 2, name: "Account B", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ), currency: CurrencyData.sampleData[1]),
        AccountWithCurrency(data: AccountData(
            id: 3, name: "Investment Account", type: AccountType.investment,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ), currency: CurrencyData.sampleData[1]),
    ]
}
