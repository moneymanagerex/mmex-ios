//
//  Theme.swift
//  MMEX
//
//  2024-10-04: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

enum FinancialColorScheme: String, ChoiceProtocol {
    case classic = "Classic"
    case colorBlindFriendly = "Blue/Orange"
    static let defaultValue = Self.classic

    var incomeColor: Color {
        switch self {
        case .classic: .green
        case .colorBlindFriendly: .blue
        }
    }

    var expenseColor: Color {
        switch self {
        case .classic: .red
        case .colorBlindFriendly: .orange
        }
    }
}

struct Theme {
    @StoredPreference var appearance: Appearance = .defaultValue
    @StoredPreference var financialColorScheme: FinancialColorScheme = .defaultValue
    @StoredPreference var numericKeypad: BoolChoice = .boolTrue
    @StoredPreference var categoryDelimiter: String = ":"
    @StoredPreferenceDictionary(key: "CategorySymbols") var symbols: [String: String]

    var tab   : TabTheme   = .init()
    var group : GroupTheme = .init()
    var item  : ItemTheme  = .init()
    var field : FieldTheme = .init()
}

extension Theme {
    init(prefix: String?) {
        self.$appearance        = prefix?.appending("appearance")
        self.$financialColorScheme = prefix?.appending("financialColorScheme")
        self.$numericKeypad     = prefix?.appending("numericKeypad")
        self.$categoryDelimiter = prefix?.appending("categoryDelimiter")

        self.tab   = .init(prefix: prefix?.appending("tab."))
        self.group = .init(prefix: prefix?.appending("group."))
        self.item  = .init(prefix: prefix?.appending("item."))
        self.field = .init(prefix: prefix?.appending("field."))
    }
}

extension Theme {
    var incomeColor: Color {
        financialColorScheme.incomeColor
    }

    var expenseColor: Color {
        financialColorScheme.expenseColor
    }

    func amountColor(for transactionType: TransactionType) -> Color {
        transactionType == .deposit ? incomeColor : expenseColor
    }

    func changeColor(for amount: Double) -> Color {
        amount >= 0 ? incomeColor : expenseColor
    }

    var decimalPad: UIKeyboardType {
        switch numericKeypad {
        case .boolTrue: .decimalPad
        default: .alphabet
        }
    }

    var textPad: UIKeyboardType {
        .default
    }
}
