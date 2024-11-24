//
//  LoadMain.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct LoadMainCount<MainRepository: RepositoryProtocol>: LoadFetchProtocol {
    typealias ValueType = Int
    let loadName: String = "Count(\(MainRepository.repositoryName))"
    let idleValue: ValueType = 0

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        MainRepository(db)?.count(from: self.table)
    }
}

struct LoadMainPluck<MainRepository: RepositoryProtocol, MainValue>: LoadFetchProtocol {
    typealias ValueType = MainValue?
    let loadName: String = "Pluck(\(MainRepository.repositoryName))"
    let idleValue: ValueType = nil

    let key: String
    let table: SQLite.Table
    let rowValue: (SQLite.Row) -> MainValue
    var state: LoadState = .init()
    var value: ValueType = nil

    init(key: String, table: SQLite.Table = MainRepository.table, with rowValue: @escaping (SQLite.Row) -> MainValue) {
        self.key = key
        self.table = table
        self.rowValue = rowValue
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        MainRepository(db)?.pluck(key: key, from: self.table, with: rowValue).toOptional()
    }
}

struct LoadMainData<MainRepository: RepositoryProtocol>: LoadFetchProtocol {
    typealias MainData = MainRepository.RepositoryData
    typealias ValueType = [DataId: MainData]
    let loadName: String = "Data(\(MainRepository.repositoryName))"
    let idleValue: ValueType = [:]

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        MainRepository(db)?.selectById(from: self.table)
    }
}

struct LoadMainValue<MainRepository: RepositoryProtocol, MainValue>: LoadFetchProtocol {
    typealias ValueType = [DataId: MainValue]
    let loadName: String = "Value(\(MainRepository.repositoryName))"
    let idleValue: ValueType = [:]

    let table: SQLite.Table
    let rowValue: (SQLite.Row) -> MainValue
    var state: LoadState = .init()
    var value: ValueType = [:]

    init(table: SQLite.Table = MainRepository.table, with rowValue: @escaping (SQLite.Row) -> MainValue) {
        self.table = table
        self.rowValue = rowValue
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        MainRepository(db)?.selectById(from: self.table, with: rowValue)
    }
}

typealias LoadMainName<MainRepository: RepositoryProtocol>
= LoadMainValue<MainRepository, String>

struct LoadMainUsed<MainRepository: RepositoryProtocol>: LoadFetchProtocol {
    typealias ValueType = Set<DataId>
    let loadName: String = "Used(\(MainRepository.repositoryName))"
    let idleValue: ValueType = []

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType

    init(table: SQLite.Table = MainRepository.table) {
        self.table = MainRepository.filterUsed(table)
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        MainRepository(db)?.select(from: self.table, with: MainRepository.fetchId).map(Set.init)
    }
}

struct LoadMainOrder<MainRepository: RepositoryProtocol>: LoadFetchProtocol {
    typealias ValueType = [DataId]
    let loadName: String = "Order(\(MainRepository.repositoryName))"
    let idleValue: ValueType = []

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType

    init(table: SQLite.Table) {
        self.table = table
        self.value = idleValue
    }

    init(order: [SQLite.Expressible]) {
        self.init(table: MainRepository.table.order(order))
    }

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        MainRepository(db)?.selectId(from: self.table)
    }
}
