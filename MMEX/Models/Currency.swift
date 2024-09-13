//
//  Currency.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct Currency: Identifiable {
    var id: Int64 // CURRENCYID
    var name: String // CURRENCYNAME
    var prefixSymbol: String? // PFX_SYMBOL
    var suffixSymbol: String? // SFX_SYMBOL
    var decimalPoint: String? // DECIMAL_POINT
    var groupSeparator: String? // GROUP_SEPARATOR
    var unitName: String? // UNIT_NAME
    var centName: String? // CENT_NAME
    var scale: Int // SCALE
    var baseConversionRate: Double? // BASECONVRATE
    var symbol: String // CURRENCY_SYMBOL
    var type: String // CURRENCY_TYPE (Fiat, Crypto)
}

extension Currency {
    static let sampleData: [Currency] = [
        Currency(id: 1, name: "US dollar", prefixSymbol: "$", suffixSymbol: "", decimalPoint: ".", groupSeparator: ",", unitName: "Dollar", centName: "Cent", scale: 100, baseConversionRate: 1.0, symbol: "USD", type: "Fiat"),
        Currency(id: 2, name: "Euro", prefixSymbol: "€", suffixSymbol: "", decimalPoint: ".", groupSeparator: " ", unitName: nil, centName: nil, scale: 100, baseConversionRate: 1.0, symbol: "EUR", type: "Fiat"),
        Currency(id: 3, name: "British pound", prefixSymbol: "£", suffixSymbol: "", decimalPoint: ".", groupSeparator: " ", unitName: "Pound", centName: "Pence", scale: 100, baseConversionRate: 1.0, symbol: "GBP", type: "Fiat")
    ]
}

extension Currency {
    // Define an empty currency
    static var empty: Currency { Currency(id: 0, name: "", prefixSymbol: nil, suffixSymbol: nil, decimalPoint: nil, groupSeparator: nil, unitName: nil, centName: nil, scale: 0, baseConversionRate: 0, symbol: "", type: "") }

    // Define the table
    static let table = Table("CURRENCYFORMATS_V1")

    // Define the columns as Expressions
    static let currencyID = Expression<Int64>("CURRENCYID")
    static let currencyName = Expression<String>("CURRENCYNAME")
    static let prefixSymbol = Expression<String?>("PFX_SYMBOL")
    static let suffixSymbol = Expression<String?>("SFX_SYMBOL")
    static let decimalPoint = Expression<String?>("DECIMAL_POINT")
    static let groupSeparator = Expression<String?>("GROUP_SEPARATOR")
    static let unitName = Expression<String?>("UNIT_NAME")
    static let centName = Expression<String?>("CENT_NAME")
    static let scale = Expression<Int>("SCALE")
    static let baseConversionRate = Expression<Double?>("BASECONVRATE")
    static let symbol = Expression<String>("CURRENCY_SYMBOL")
    static let type = Expression<String>("CURRENCY_TYPE")
}

extension Currency {
    /// A `NumberFormatter` configured specifically for the currency.
    var formatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        // Apply currency-specific formatting based on this Currency instance
        numberFormatter.currencySymbol = self.prefixSymbol ?? self.symbol
        numberFormatter.currencyGroupingSeparator = self.groupSeparator ?? ","
        numberFormatter.currencyDecimalSeparator = self.decimalPoint ?? "."
        numberFormatter.maximumFractionDigits = self.scale
        
        return numberFormatter
    }
    
    /// Format a given amount using the currency's `NumberFormatter`.
    func format(amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Helper method to convert and format the amount into base currency using the exchange rate.
    func formatAsBaseCurrency(amount: Double, baseCurrencyRate: Double?) -> String {
        guard let conversionRate = baseCurrencyRate ?? self.baseConversionRate else {
            return format(amount: amount)
        }
        
        let baseAmount = amount * conversionRate
        return formatter.string(from: NSNumber(value: baseAmount)) ?? "\(baseAmount)"
    }
}
