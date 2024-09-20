//
//  Currency.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct Currency: ExportableEntity {
    var id: Int64                   // CURRENCYID INTEGER PRIMARY KEY
    var name: String                // CURRENCYNAME TEXT COLLATE NOCASE UNIQUE
    var prefixSymbol: String?       // PFX_SYMBOL TEXT
    var suffixSymbol: String?       // SFX_SYMBOL TEXT
    var decimalPoint: String?       // DECIMAL_POINT TEXT
    var groupSeparator: String?     // GROUP_SEPARATOR TEXT
    var unitName: String?           // UNIT_NAME TEXT COLLATE NOCASE
    var centName: String?           // CENT_NAME TEXT COLLATE NOCASE
    var scale: Int?                 // SCALE INTEGER
    var baseConversionRate: Double? // BASECONVRATE NUMERIC
    var symbol: String              // CURRENCY_SYMBOL TEXT COLLATE NOCASE UNIQUE
    var type: String                // CURRENCY_TYPE TEXT (Fiat, Crypto)
}

extension Currency {
    // empty currency
    static var empty: Currency { Currency(
        id: 0, name: "", prefixSymbol: nil, suffixSymbol: nil,
        decimalPoint: nil, groupSeparator: nil, unitName: nil, centName: nil,
        scale: 0, baseConversionRate: 0, symbol: "", type: ""
    ) }
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
        numberFormatter.maximumFractionDigits = self.scale ?? 0
        
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

extension Currency {
    static let sampleData: [Currency] = [
        Currency(
            id: 1, name: "US dollar", prefixSymbol: "$", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: ",", unitName: "Dollar", centName: "Cent",
            scale: 100, baseConversionRate: 1.0, symbol: "USD", type: "Fiat"
        ),
        Currency(
            id: 2, name: "Euro", prefixSymbol: "€", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: " ", unitName: nil, centName: nil,
            scale: 100, baseConversionRate: 1.0, symbol: "EUR", type: "Fiat"
        ),
        Currency(
            id: 3, name: "British pound", prefixSymbol: "£", suffixSymbol: "",
            decimalPoint: ".", groupSeparator: " ", unitName: "Pound", centName: "Pence",
            scale: 100, baseConversionRate: 1.0, symbol: "GBP", type: "Fiat"
        )
    ]
}

