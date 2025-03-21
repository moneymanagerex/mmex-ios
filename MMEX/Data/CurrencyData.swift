//
//  CurrencyData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

enum CurrencyType: String, ChoiceProtocol {
    case fiat   = "Fiat"
    case crypto = "Crypto"
    static let defaultValue = Self.fiat
}

struct CurrencyData: DataProtocol {
    var id             : DataId       = .void
    var name           : String       = ""
    var prefixSymbol   : String       = ""
    var suffixSymbol   : String       = ""
    var decimalPoint   : String       = ""
    var groupSeparator : String       = ""
    var unitName       : String       = ""
    var centName       : String       = ""
    var scale          : Int          = 0
    var baseConvRate   : Double       = 0.0
    var symbol         : String       = ""
    var type           : CurrencyType = .defaultValue

    // unique(name)
    // unique(symbol)
}

extension CurrencyData {
    static let dataName = ("Currency", "Currencies")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id     = .void
        name   = Self.copy(of: name)
        symbol = Self.copy(of: symbol)
    }

    mutating func resolveConstraint(conflictingWith existing: CurrencyData? = nil) -> Bool {
        /// TODO column level
        return false
    }
}

typealias CurrencyFormatter = NumberFormatter

extension CurrencyData {
    var formatter: CurrencyFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.positivePrefix    = self.prefixSymbol
        nf.negativePrefix    = "-" + self.prefixSymbol
        nf.positiveSuffix    = self.suffixSymbol
        nf.negativeSuffix    = self.suffixSymbol
        nf.decimalSeparator  = self.decimalPoint
        nf.groupingSeparator = self.groupSeparator
        let frac = self.scale > 0 ? Int(ceil(log10(Double(self.scale)))) : 0
        nf.minimumFractionDigits = frac
        nf.maximumFractionDigits = frac
        return nf
    }
}

extension Double {
    func formatted(by formatter: CurrencyFormatter? = nil) -> String {
        formatter?.string(from: NSNumber(value: self)) ??
        String(format: "%.2f", self)
    }
}

extension CurrencyData {
    /// A `NumberFormatter` configured specifically for the currency.
    var formatterOld: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .currency

        // Apply currency-specific formatting based on this Currency instance
        nf.currencySymbol = self.prefixSymbol
        nf.currencyGroupingSeparator = self.groupSeparator
        nf.currencyDecimalSeparator = self.decimalPoint
        nf.minimumFractionDigits = Int(log10(Double(self.scale > 0 ? self.scale : 1)))
        nf.maximumFractionDigits = Int(log10(Double(self.scale > 0 ? self.scale : 1)))

        return nf
    }

    /// Format a given amount using the currency's `NumberFormatter`.
    func formatOld(amount: Double) -> String {
        log.trace("DEBUG: CurrencyData.formatOld(): name=\(name), scale=\(scale)")
        return switch formatterOld.string(from: NSNumber(value: amount)) {
        case .some(let s): s + self.suffixSymbol
        case .none: "\(amount)"
        }
    }

    // TODO: move to higher level where base currency is maintained
    /// Helper method to convert and format the amount into base currency using the exchange rate.
    func formatAsBaseCurrency(amount: Double, baseCurrencyRate: Double?) -> String {
        let baseAmount = amount * (baseCurrencyRate ?? self.baseConvRate)
        // TODO: use the formatter of the base currency
        return formatterOld.string(from: NSNumber(value: baseAmount)) ?? "\(baseAmount)"
    }
}

struct CurrencyInfo {
    let name         : String
    let baseConvRate : Double
    let formatter    : CurrencyFormatter
    let symbol       : String

    init(_ data: CurrencyData) {
        self.name         = data.name
        self.baseConvRate = data.baseConvRate
        self.formatter    = data.formatter
        self.symbol       = data.symbol
    }
}

extension CurrencyData {
    static let sampleData: [CurrencyData] = [
        CurrencyData(
            id: 1, name: "US dollar", prefixSymbol: "$", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: ",", unitName: "Dollar", centName: "Cent",
            scale: 100, baseConvRate: 1.0, symbol: "USD", type: .fiat
        ),
        CurrencyData(
            id: 2, name: "Euro", prefixSymbol: "€", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: " ", unitName: "", centName: "",
            scale: 100, baseConvRate: 1.0, symbol: "EUR", type: .fiat
        ),
        CurrencyData(
            id: 3, name: "British pound", prefixSymbol: "£", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: " ", unitName: "Pound", centName: "Pence",
            scale: 100, baseConvRate: 1.0, symbol: "GBP", type: .fiat
        ),
    ]

    static let sampleDataById: [DataId: CurrencyData] = Dictionary(
        uniqueKeysWithValues: sampleData.map { ($0.id, $0 ) }
    )

    static let sampleDataName: [(DataId, String)] = CurrencyData.sampleData.map {
        ($0.id, $0.name)
    }
}
