//
//  LoadMain.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct LoadMainCount<MainRepository: RepositoryProtocol>: LoadProtocol {
    typealias ValueType = Int

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: Int = 0

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.count(from: self.table)
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: LoadMainCount.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = 0
        state.unloaded()
    }
}

struct LoadMainData<MainRepository: RepositoryProtocol>: LoadProtocol {
    typealias MainData = MainRepository.RepositoryData
    typealias ValueType = [DataId: MainData]

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType = [:]

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.selectById(from: self.table)
    }
    
    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: LoadMainData.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = [:]
        state.unloaded()
    }
}

struct LoadMainValue<MainRepository: RepositoryProtocol, MainValue>: LoadProtocol {
    typealias ValueType = [DataId: MainValue]

    let table: SQLite.Table
    let rowValue: (SQLite.Row) -> MainValue
    var state: LoadState = .init()
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
        log.trace("DEBUG: LoadMainValue.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = [:]
        state.unloaded()
    }
}

typealias LoadMainName<MainRepository: RepositoryProtocol>
= LoadMainValue<MainRepository, String>

struct LoadMainOrder<MainRepository: RepositoryProtocol>: LoadProtocol {
    typealias ValueType = [DataId]

    let table: SQLite.Table
    var state: LoadState = .init()
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
        log.trace("DEBUG: LoadMainOrder.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = []
        state.unloaded()
    }
}

struct LoadMainUsed<MainRepository: RepositoryProtocol>: LoadProtocol {
    typealias ValueType = Set<DataId>

    let table: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType = []

    init(table: SQLite.Table = MainRepository.table) {
        self.table = MainRepository.filterUsed(table)
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        MainRepository(env)?.selectId(from: self.table).map { Set($0) }
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: LoadMainUsed.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = []
        state.unloaded()
    }
}
