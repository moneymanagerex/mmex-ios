//
//  Currency.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

enum CurrencyType: String, EnumCollateNoCase {
    case fiat   = "Fiat"
    case crypto = "Crypto"
    static let defaultValue = Self.fiat
}

struct CurrencyData: ExportableEntity, CurrencyFormatProtocol {
    var id             : Int64        = 0
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
    var type           : CurrencyType = CurrencyType.defaultValue
}

extension CurrencyData: DataProtocol {
    static let dataName = "Currency"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

// TODO: remove CurrencyFormat; use CurrencyData instead
protocol CurrencyFormatProtocol {
    var name           : String { get }
    var prefixSymbol   : String { get }
    var suffixSymbol   : String { get }
    var decimalPoint   : String { get }
    var groupSeparator : String { get }
    var scale          : Int    { get }
    var baseConvRate   : Double { get }
}

struct CurrencyFormat: CurrencyFormatProtocol {
    let name           : String
    let prefixSymbol   : String
    let suffixSymbol   : String
    let decimalPoint   : String
    let groupSeparator : String
    let scale          : Int
    let baseConvRate   : Double
}

extension CurrencyFormatProtocol {
    var toCurrencyFormat: CurrencyFormat { CurrencyFormat(
        name           : self.name,
        prefixSymbol   : self.prefixSymbol,
        suffixSymbol   : self.suffixSymbol,
        decimalPoint   : self.decimalPoint,
        groupSeparator : self.groupSeparator,
        scale          : self.scale,
        baseConvRate   : self.baseConvRate
    ) }
}

extension CurrencyFormatProtocol {
    /// A `NumberFormatter` configured specifically for the currency.
    var formatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .currency

        // Apply currency-specific formatting based on this Currency instance
        nf.currencySymbol = self.prefixSymbol
        nf.currencyGroupingSeparator = self.groupSeparator
        nf.currencyDecimalSeparator = self.decimalPoint
        nf.maximumFractionDigits = self.scale

        return nf
    }

    /// Format a given amount using the currency's `NumberFormatter`.
    func format(amount: Double) -> String {
        return switch formatter.string(from: NSNumber(value: amount)) {
        case .some(let s): s + self.suffixSymbol
        case .none: "\(amount)"
        }
    }

    // TODO: move to higher level where base currency is maintained
    /// Helper method to convert and format the amount into base currency using the exchange rate.
    func formatAsBaseCurrency(amount: Double, baseCurrencyRate: Double?) -> String {
        let baseAmount = amount * (baseCurrencyRate ?? self.baseConvRate)
        // TODO: use the formatter of the base currency
        return formatter.string(from: NSNumber(value: baseAmount)) ?? "\(baseAmount)"
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
}
