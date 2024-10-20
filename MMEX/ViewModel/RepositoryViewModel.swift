//
//  RepositoryViewModel.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

@MainActor
class RepositoryViewModel: ObservableObject {
    let env: EnvironmentManager

    @Published var manageCount: RepositoryLoadState<Void> = .init()

    typealias U = CurrencyRepository
    @Published var currencyCount : RepositoryLoadDataCount<U> = .init()
    @Published var currencyDict  : RepositoryLoadDataDict<U> = .init()
    @Published var currencyOrder : RepositoryLoadDataOrder<U> = .init(expr: [U.col_name])
    @Published var currencyUsed  : RepositoryLoadDataUsed<U> = .init()
    @Published var currencyList  : RepositoryLoadList<U> = .init()

    typealias A = AccountRepository
    @Published var accountCount : RepositoryLoadDataCount<A> = .init()
    @Published var accountDict  : RepositoryLoadDataDict<A> = .init()
    @Published var accountOrder : RepositoryLoadDataOrder<A> = .init(expr: [A.col_name])
    @Published var accountUsed  : RepositoryLoadDataUsed<A> = .init()
    @Published var accountGroup : RepositoryLoadGroup<AccountGroupChoice> = .init()
    @Published var accountList  : RepositoryLoadList<A> = .init()

    typealias E = AssetRepository
    @Published var assetCount : RepositoryLoadDataCount<E> = .init()
    @Published var assetDict  : RepositoryLoadDataDict<E> = .init()
    @Published var assetOrder : RepositoryLoadDataOrder<E> = .init(expr: [E.col_name])
    @Published var assetUsed  : RepositoryLoadDataUsed<E> = .init()
    @Published var assetList  : RepositoryLoadList<E> = .init()

    typealias S = StockRepository
    @Published var stockCount : RepositoryLoadDataCount<S> = .init()
    @Published var stockDict  : RepositoryLoadDataDict<S> = .init()
    @Published var stockOrder : RepositoryLoadDataOrder<S> = .init(expr: [S.col_name])
    @Published var stockUsed  : RepositoryLoadDataUsed<S> = .init()
    @Published var stockList  : RepositoryLoadList<S> = .init()

    typealias C = CategoryRepository
    @Published var categoryCount    : RepositoryLoadDataCount<C> = .init()

    typealias P = PayeeRepository
    @Published var payeeCount : RepositoryLoadDataCount<P> = .init()
    @Published var payeeDict  : RepositoryLoadDataDict<P> = .init()
    @Published var payeeOrder : RepositoryLoadDataOrder<P> = .init(expr: [P.col_name])
    @Published var payeeUsed  : RepositoryLoadDataUsed<P> = .init()
    @Published var payeeList  : RepositoryLoadList<P> = .init()

    typealias T = TransactionRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount    : RepositoryLoadDataCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    @Published var scheduledCount    : RepositoryLoadDataCount<R> = .init()

    //var currencyName : RepositoryLoad<[(DataId, String)]>     = .init([])
    //var accountAttachmentCount : RepositoryLoad<[DataId: Int]>         = .init([:])
    
    init(env: EnvironmentManager) {
        self.env = env
    }
}

extension RepositoryViewModel {
    func load<RepositoryLoadType>(
        queue: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<RepositoryViewModel, RepositoryLoadType>
    ) where RepositoryLoadType: RepositoryLoadProtocol {
        if case .idle = self[keyPath: keyPath].state {
            self[keyPath: keyPath].state = .loading
            queue.addTask(priority: .background) {
                let data = await self[keyPath: keyPath].load(env: self.env)
                await MainActor.run {
                    if let data { self[keyPath: keyPath].state = .ready(data) }
                    else { self[keyPath: keyPath].state = .error("Cannot load data.") }
                }
                return data != nil
            }
        }
    }

    func allOk(queue: TaskGroup<Bool>) async -> Bool {
        var queueOk = true
        for await taskOk in queue {
            if !taskOk { queueOk = false }
        }
        return queueOk
    }
}

extension RepositoryViewModel {
    func loadList<RepositoryType>(_ list: RepositoryLoadList<RepositoryType>) async {
        if list.type == U.self {
            async let _ = loadCurrencyList()
        } else if list.type == A.self {
            async let _ = loadAccountList()
        } else if list.type == E.self {
            async let _ = loadAssetList()
        } else if list.type == S.self {
            async let _ = loadStockList()
        } else if list.type == P.self {
            async let _ = loadPayeeList()
        }
    }

    func unloadList<RepositoryType>(_ list: RepositoryLoadList<RepositoryType>) {
        if list.type == U.self {
            unloadCurrencyList()
        } else if list.type == A.self {
            unloadAccountList()
        } else if list.type == E.self {
            unloadAssetList()
        } else if list.type == S.self {
            unloadStockList()
        } else if list.type == P.self {
            unloadPayeeList()
        }
    }

    func loadAll() async {
        async let _ = loadManage()
        async let _ = loadCurrencyList()
        async let _ = loadAccountList()
        async let _ = loadAssetList()
        async let _ = loadStockList()
        async let _ = loadPayeeList()
    }

    func unloadAll() {
        unloadManege()
        unloadCurrencyList()
        unloadAccountList()
        unloadAssetList()
        unloadStockList()
        unloadPayeeList()
    }
}
