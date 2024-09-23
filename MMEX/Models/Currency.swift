//
//  Currency.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct CurrencyData: ExportableEntity {
    var id             : Int64
    var name           : String
    var prefixSymbol   : String
    var suffixSymbol   : String
    var decimalPoint   : String
    var groupSeparator : String
    var unitName       : String
    var centName       : String
    var scale          : Int
    var baseConvRate   : Double
    var symbol         : String
    var type           : String

    init(
        id             : Int64  = 0,
        name           : String = "",
        prefixSymbol   : String = "",
        suffixSymbol   : String = "",
        decimalPoint   : String = "",
        groupSeparator : String = "",
        unitName       : String = "",
        centName       : String = "",
        scale          : Int    = 0,
        baseConvRate   : Double = 0.0,
        symbol         : String = "",
        type           : String = ""
    ) {
        self.id             = id
        self.name           = name
        self.prefixSymbol   = prefixSymbol
        self.suffixSymbol   = suffixSymbol
        self.decimalPoint   = decimalPoint
        self.groupSeparator = groupSeparator
        self.unitName       = unitName
        self.centName       = centName
        self.scale          = scale
        self.baseConvRate   = baseConvRate
        self.symbol         = symbol
        self.type           = type
    }
}

extension CurrencyData: DataProtocol {
    static let modelName = "Currency"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

struct CurrencyFull: FullProtocol {
    var data: CurrencyData
}

extension CurrencyData {
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
            scale: 100, baseConvRate: 1.0, symbol: "USD", type: "Fiat"
        ),
        CurrencyData(
            id: 2, name: "Euro", prefixSymbol: "€", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: " ", unitName: "", centName: "",
            scale: 100, baseConvRate: 1.0, symbol: "EUR", type: "Fiat"
        ),
        CurrencyData(
            id: 3, name: "British pound", prefixSymbol: "£", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: " ", unitName: "Pound", centName: "Pence",
            scale: 100, baseConvRate: 1.0, symbol: "GBP", type: "Fiat"
        ),
    ]
}
