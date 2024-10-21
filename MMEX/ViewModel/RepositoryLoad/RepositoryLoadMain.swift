//
//  RepositoryLoadMain.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct RepositoryLoadMainCount<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias LoadType = Int

    let table: SQLite.Table
    var state: RepositoryLoadState<LoadType> = .init()

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) -> LoadType? {
        MainRepository(env)?.count(from: self.table)
    }
}

struct RepositoryLoadMainData<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias MainData = MainRepository.RepositoryData
    typealias LoadType = [DataId: MainData]

    let table: SQLite.Table
    var state: RepositoryLoadState<LoadType> = .init()

    init(table: SQLite.Table = MainRepository.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) -> LoadType? {
        MainRepository(env)?.selectById(from: self.table)
    }
}

struct RepositoryLoadMainValue<MainRepository: RepositoryProtocol, ValueType>: RepositoryLoadProtocol {
    typealias MainData = MainRepository.RepositoryData
    typealias LoadType = [DataId: ValueType]

    let table: SQLite.Table
    let fetch: (SQLite.Row) -> ValueType
    var state: RepositoryLoadState<LoadType> = .init()

    init(table: SQLite.Table = MainRepository.table, fetch: @escaping (SQLite.Row) -> ValueType) {
        self.table = table
        self.fetch = fetch
    }

    func load(env: EnvironmentManager) -> LoadType? {
        MainRepository(env)?.selectById(from: self.table, with: fetch)
    }
}

typealias RepositoryLoadMainName<MainRepository: RepositoryProtocol>
= RepositoryLoadMainValue<MainRepository, String>

struct RepositoryLoadMainOrder<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias LoadType = [DataId]
    let table: SQLite.Table
    var state: RepositoryLoadState<LoadType> = .init()

    init(table: SQLite.Table) {
        self.table = table
    }

    init(order: [SQLite.Expressible]) {
        self.table = MainRepository.table.order(order)
    }

    func load(env: EnvironmentManager) -> LoadType? {
        MainRepository(env)?.selectId(from: self.table)
    }
}

struct RepositoryLoadMainUsed<MainRepository: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias LoadType = Set<DataId>
    let table: SQLite.Table
    var state: RepositoryLoadState<LoadType> = .init()

    init(table: SQLite.Table = MainRepository.table) {
        self.table = MainRepository.filterUsed(table)
    }

    func load(env: EnvironmentManager) -> LoadType? {
        MainRepository(env)?.selectId(from: self.table).map { Set($0) }
    }
}
