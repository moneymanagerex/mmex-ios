//
//  DataCache.swift
//  MMEX
//
//  Created 2024-10-01 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct CurrencyInfo {
    let name         : String
    let baseConvRate : Double
    let formatter    : CurrencyFormatter

    init(_ data: CurrencyData) {
        self.name         = data.name
        self.baseConvRate = data.baseConvRate
        self.formatter    = data.formatter
    }
}

typealias CurrencyCache = [Int64: CurrencyInfo]

extension CurrencyCache {
    mutating func load(_ dict: [Int64: CurrencyData]) {
        self = dict.mapValues { data in CurrencyInfo(data) }
    }

    mutating func update(id: Int64, data: CurrencyData) {
        self[id] = CurrencyInfo(data)
    }

    mutating func unload() {
        self = [:]
    }
}
