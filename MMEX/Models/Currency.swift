//
//  Currency.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation

struct Currency: Identifiable {
    var id: Int // CURRENCYID
    var name: String // CURRENCYNAME
    var symbol: String // SYMBOL
    var exchangeRate: Double // EXCHANGERATE
    var isBase: Bool // ISBASECURRENCY
}
