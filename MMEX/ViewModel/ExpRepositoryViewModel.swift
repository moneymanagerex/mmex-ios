//
//  RpositoryViewModel.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

enum ExpRepositoryLoadState<DataType: Copyable>: Copyable {
    case error(String)
    case idle
    case loading
    case ready(DataType)
    
    init() {
        self = .idle
    }
}

@MainActor
protocol ExpRepositoryLoadProtocol: AnyObject, ObservableObject {
    associatedtype DataType: Copyable
    var state: ExpRepositoryLoadState<DataType> { get set }
}

extension ExpRepositoryLoadProtocol {
    func load(
        with loadData: @escaping () -> DataType?
    ) async -> Bool? {
        switch state {
        case .idle:
            self.state = .loading
            return await Task {
                let data: DataType? = loadData()
                await MainActor.run {
                    if let data {
                        self.state = .ready(data)
                    } else {
                        self.state = .error("Cannot load data.")
                    }
                }
                return data != nil
            }.value
        case .ready(_): return true
        case .error(_), .loading: return nil
        }
    }
}

@MainActor
class ExpRepositoryLoadCount<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    @Published var state: ExpRepositoryLoadState<Int> = .idle
    let table: SQLite.Table

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) async -> Bool? {
        return await load() { () in RepositoryType(env)?.count(from: self.table) }
    }
}

@MainActor
class ExpRepositoryLoadDataById<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    typealias RepositoryData = RepositoryType.RepositoryData
    @Published var state: ExpRepositoryLoadState<[DataId: RepositoryData]> = .idle
    let table: SQLite.Table

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) async -> Bool? {
        return await load() { () in RepositoryType(env)?.selectById(from: self.table) }
    }
}

@MainActor
class ExpRepositoryLoadOrder<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    @Published var state: ExpRepositoryLoadState<[DataId]> = .idle
    let table: SQLite.Table

    init(table: SQLite.Table) {
        self.table = table
    }

    init(expr: [SQLite.Expressible]) {
        self.table = RepositoryType.table.order(expr)
    }

    func load(env: EnvironmentManager) async -> Bool? {
        return await load() { () in RepositoryType(env)?.selectId(from: self.table) }
    }
}

@MainActor
class ExpRepositoryLoadUsed<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    @Published var state: ExpRepositoryLoadState<Set<DataId>> = .idle
    let table: SQLite.Table

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) async -> Bool? {
        return await load() { () in RepositoryType(env)?.selectId(
            from: RepositoryType.filterUsed(self.table)
        ).map { Set($0) } }
    }
}

@MainActor
class ExpRepositoryViewModel: ObservableObject {
    typealias C = CurrencyRepository
    @Published var currencyCount    : ExpRepositoryLoadCount<C> = .init()
    @Published var currencyDataById : ExpRepositoryLoadDataById<C> = .init()
    @Published var currencyOrder    : ExpRepositoryLoadOrder<C> = .init(expr: [C.col_name])
    @Published var currencyUsed     : ExpRepositoryLoadUsed<C> = .init()

    typealias A = AccountRepository
    @Published var accountCount    : ExpRepositoryLoadCount<A> = .init()
    @Published var accountDataById : ExpRepositoryLoadDataById<A> = .init()
    @Published var accountOrder    : ExpRepositoryLoadOrder<A> = .init(expr: [A.col_name])
    @Published var accountUsed     : ExpRepositoryLoadUsed<A> = .init()

    //var currencyName : ExpRepositoryLoad<[(DataId, String)]>     = .init([])
    //var accountAttachmentCount : ExpRepositoryLoad<[DataId: Int]>         = .init([:])

    //var currencyGroup : ExpRepositoryGroup<CurrencyGroup> = .init()
    //var accountGroup  : ExpRepositoryGroup<AccountGroup>  = .init()
}
