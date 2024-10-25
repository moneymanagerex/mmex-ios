//
//  RepositoryLoadMain.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct RepositoryLoadMainList<MainRepository: RepositoryProtocol> {
    var state: RepositoryLoadState = .init()
}

struct RepositoryLoadMainCount<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias ValueType = Int

    let table: SQLite.Table
    var state: RepositoryLoadState = .init()
    var value: Int = 0

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.count(from: self.table)
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainCount.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = 0
        state.unloaded()
    }
}

struct RepositoryLoadMainData<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias MainData = MainRepository.RepositoryData
    typealias ValueType = [DataId: MainData]

    let table: SQLite.Table
    var state: RepositoryLoadState = .init()
    var value: ValueType = [:]

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.selectById(from: self.table)
    }
    
    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainData.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = [:]
        state.unloaded()
    }
}

struct RepositoryLoadMainValue<MainRepository: RepositoryProtocol, MainValue>: RepositoryLoadProtocol {
    typealias ValueType = [DataId: MainValue]

    let table: SQLite.Table
    let rowValue: (SQLite.Row) -> MainValue
    var state: RepositoryLoadState = .init()
    var value: ValueType = [:]

    init(table: SQLite.Table = MainRepository.table, with rowValue: @escaping (SQLite.Row) -> MainValue) {
        self.table = table
        self.rowValue = rowValue
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.selectById(from: self.table, with: rowValue)
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainValue.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = [:]
        state.unloaded()
    }
}

typealias RepositoryLoadMainName<MainRepository: RepositoryProtocol>
= RepositoryLoadMainValue<MainRepository, String>

struct RepositoryLoadMainOrder<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias ValueType = [DataId]

    let table: SQLite.Table
    var state: RepositoryLoadState = .init()
    var value: ValueType = []

    init(table: SQLite.Table) {
        self.table = table
    }

    init(order: [SQLite.Expressible]) {
        self.table = MainRepository.table.order(order)
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.selectId(from: self.table)
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainOrder.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = []
        state.unloaded()
    }
}

struct RepositoryLoadMainUsed<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias ValueType = Set<DataId>

    let table: SQLite.Table
    var state: RepositoryLoadState = .init()
    var value: ValueType = []

    init(table: SQLite.Table = MainRepository.table) {
        self.table = MainRepository.filterUsed(table)
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.selectId(from: self.table).map { Set($0) }
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainUsed.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = []
        state.unloaded()
    }
}
