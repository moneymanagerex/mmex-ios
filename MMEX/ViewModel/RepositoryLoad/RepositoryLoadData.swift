//
//  RepositoryLoadData.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct RepositoryLoadDataCount<RepositoryType: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias DataType = Int

    let table: SQLite.Table
    var state: RepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.count(from: self.table)
    }
}

struct RepositoryLoadDataDict<RepositoryType: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias RepositoryData = RepositoryType.RepositoryData
    typealias DataType = [DataId: RepositoryData]

    let table: SQLite.Table
    var state: RepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.selectById(from: self.table)
    }
}

struct RepositoryLoadDataValue<RepositoryType: RepositoryProtocol, DataValue>: RepositoryLoadProtocol {
    typealias RepositoryData = RepositoryType.RepositoryData
    typealias DataType = [DataId: DataValue]

    let table: SQLite.Table
    let fetch: (SQLite.Row) -> DataValue
    var state: RepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table, fetch: @escaping (SQLite.Row) -> DataValue) {
        self.table = table
        self.fetch = fetch
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.selectById(from: self.table, with: fetch)
    }
}

typealias RepositoryLoadDataName<RepositoryType: RepositoryProtocol>
= RepositoryLoadDataValue<RepositoryType, String>

struct RepositoryLoadDataOrder<RepositoryType: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias DataType = [DataId]
    let table: SQLite.Table
    var state: RepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table) {
        self.table = table
    }

    init(expr: [SQLite.Expressible]) {
        self.table = RepositoryType.table.order(expr)
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.selectId(from: self.table)
    }
}

struct RepositoryLoadDataUsed<RepositoryType: RepositoryProtocol>: RepositoryLoadProtocol {
    typealias DataType = Set<DataId>
    let table: SQLite.Table
    var state: RepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = RepositoryType.filterUsed(table)
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.selectId(from: self.table).map { Set($0) }
    }
}
