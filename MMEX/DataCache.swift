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
    init() {
        self = [:]
    }

    mutating func load(_ dict: [Int64: CurrencyData]) {
        self = dict.mapValues { data in CurrencyInfo(data) }
    }

    mutating func update(id: Int64, data: CurrencyData) {
        self[id] = CurrencyInfo(data)
    }

    mutating func unload() {
        self.removeAll()
    }
}

struct AccountInfo {
    var name            : String
    var type            : AccountType
    var status          : AccountStatus
    var initialDate     : String
    var initialBal      : Double
    var currencyId      : Int64
    var statementLocked : Bool
    var statementDate   : String
    var minimumBalance  : Double
    var creditLimit     : Double
    
    init(_ data: AccountData) {
        self.name            = data.name
        self.type            = data.type
        self.status          = data.status
        self.initialDate     = data.initialDate
        self.initialBal      = data.initialBal
        self.currencyId      = data.currencyId
        self.statementLocked = data.statementLocked
        self.statementDate   = data.statementDate
        self.minimumBalance  = data.minimumBalance
        self.creditLimit     = data.creditLimit
    }
}

typealias AccountCache = [Int64: AccountInfo]

extension AccountCache {
    init() {
        self = [:]
    }

    mutating func load(_ dict: [Int64: AccountData]) {
        self = dict.mapValues { data in AccountInfo(data) }
    }

    mutating func update(id: Int64, data: AccountData) {
        self[id] = AccountInfo(data)
    }

    mutating func unload() {
        self = [:]
    }
}
