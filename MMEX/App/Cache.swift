//
//  Cache.swift
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

typealias CurrencyCache = [DataId: CurrencyInfo]

extension CurrencyCache {
    init() {
        self = [:]
    }

    mutating func load(_ dict: [DataId: CurrencyData]) {
        self = dict.mapValues { data in CurrencyInfo(data) }
    }

    mutating func update(id: DataId, data: CurrencyData) {
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
    var initialDate     : DateString
    var initialBal      : Double
    var currencyId      : DataId
    var statementLocked : Bool
    var statementDate   : DateString
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

typealias AccountCache = [DataId: AccountInfo]

extension AccountCache {
    init() {
        self = [:]
    }

    mutating func load(_ dict: [DataId: AccountData]) {
        self = dict.mapValues { data in AccountInfo(data) }
    }

    mutating func update(id: DataId, data: AccountData) {
        self[id] = AccountInfo(data)
    }

    mutating func unload() {
        self.removeAll()
    }
}
