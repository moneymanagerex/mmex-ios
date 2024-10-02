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
    
    // Utility to fetch associated SF Symbol for each account type
    var symbolName: String {
        switch self {
        case .cash:
            return "dollarsign.circle.fill"
        case .checking:
            return "banknote.fill"
        case .creditCard:
            return "creditcard.fill"
        case .loan:
            return "building.columns.fill"
        case .term:
            return "calendar.circle.fill"
        case .investment:
            return "chart.bar.fill"
        case .asset:
            return "house.fill"
        case .shares:
            return "person.3.fill"
        }
    }
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

struct AccountFlow {
    let inflow  : Double
    let outflow : Double
}

extension AccountFlow {
    var diff: Double { inflow - outflow }
}

typealias AccountFlowByStatus = [TransactionStatus: AccountFlow]

extension AccountFlowByStatus {
    var diffTotal      : Double {
        (self[.none]?       .diff ?? 0.0) +
        (self[.reconciled]? .diff ?? 0.0) +
        (self[.followUp]?   .diff ?? 0.0) +
        (self[.duplicate]?  .diff ?? 0.0)
    }
    var diffReconciled : Double { self[.reconciled]?  .diff ?? 0.0 }
}

extension AccountData {
    static let sampleData : [AccountData] = [
        AccountData(
            id: 1, name: "Account A", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 100.0, favoriteAcct: "TRUE", currencyId: 1
        ),
        AccountData(
            id: 2, name: "Account B", type: AccountType.cash,
            status: AccountStatus.open, notes:"",
            initialBal: 200.0, favoriteAcct: "TRUE", currencyId: 2
        ),
        AccountData(
            id: 3, name: "Investment Account", type: AccountType.investment,
            status: AccountStatus.open, notes:"",
            initialBal: 0.0, favoriteAcct: "TRUE", currencyId: 2
        ),
    ]

    static var sampleDataIds : [Int64] {
        sampleData.map { $0.id }
    }

    static let sampleDataById: [Int64: AccountData] = Dictionary(
        uniqueKeysWithValues: sampleData.map { ($0.id, $0 ) }
    )
}
