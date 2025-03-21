//
//  AccountData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import Foundation
import SQLite

enum AccountStatus: String, ChoiceProtocol {
    case open   = "Open"
    case closed = "Closed"
    static let defaultValue = Self.closed

    var isOpen: Bool {
        get { self == .open }
        set { self = newValue ? .open : .closed }
    }
}

enum AccountFavorite: String, ChoiceProtocol {
    case boolFalse = "FALSE"
    case boolTrue  = "TRUE"
    static let defaultValue = Self.boolFalse

    var asBool: Bool {
        get { self == .boolTrue }
        set { self = newValue ? .boolTrue : .boolFalse }
    }
}

enum AccountType: String, ChoiceProtocol {
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
            return "chart.line.uptrend.xyaxis"
        }
    }
}

struct AccountData: DataProtocol {
    var id              : DataId          = .void
    var name            : String          = ""
    var type            : AccountType     = .defaultValue
    var num             : String          = ""
    var status          : AccountStatus   = .defaultValue
    var notes           : String          = ""
    var heldAt          : String          = ""
    var website         : String          = ""
    var contactInfo     : String          = ""
    var accessInfo      : String          = ""
    var initialDate     : DateString      = DateString("")
    var initialBal      : Double          = 0.0
    var favoriteAcct    : AccountFavorite = .defaultValue
    var currencyId      : DataId          = .void
    var statementLocked : Bool            = false
    var statementDate   : DateString      = DateString("")
    var minimumBalance  : Double          = 0.0
    var creditLimit     : Double          = 0.0
    var interestRate    : Double          = 0.0
    var paymentDueDate  : DateString      = DateString("")
    var minimumPayment  : Double          = 0.0
    
    // unique(name)
}

extension AccountData {
    static let dataName = ("Account", "Accounts")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }

    mutating func resolveConstraint(conflictingWith existing: AccountData? = nil) -> Bool {
        /// TODO column level
        self.name = "\(self.name):\(self.id)"
        return true
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
            status: AccountStatus.open, notes: "line 1\nline 2",
            initialDate: DateString(Date()),
            initialBal: 100.0, favoriteAcct: .boolTrue, currencyId: 1
        ),
        AccountData(
            id: 2, name: "Account B", type: AccountType.cash,
            status: AccountStatus.open, notes: "note",
            initialDate: DateString(Date()),
            initialBal: 200.0, favoriteAcct: .boolTrue, currencyId: 2
        ),
        AccountData(
            id: 3, name: "Inv Account", type: AccountType.investment,
            status: AccountStatus.open, notes: "",
            initialDate: DateString(Date()),
            initialBal: 2000.0, favoriteAcct: .boolTrue, currencyId: 1
        ),
        AccountData(
            id: 4, name: "House", type: AccountType.asset,
            status: AccountStatus.open, notes: "",
            initialDate: DateString(Date()),
            initialBal: 0.0, favoriteAcct: .boolTrue, currencyId: 1
        ),
        AccountData(
            id: 5, name: "Car", type: AccountType.asset,
            status: AccountStatus.open, notes: "",
            initialDate: DateString(Date()),
            initialBal: 0.0, favoriteAcct: .boolFalse, currencyId: 1
        ),
    ]

    static var sampleDataIds : [DataId] {
        sampleData.map { $0.id }
    }

    static let sampleDataById: [DataId: AccountData] = Dictionary(
        uniqueKeysWithValues: sampleData.map { ($0.id, $0 ) }
    )
}
