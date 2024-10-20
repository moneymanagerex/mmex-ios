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
    func loadManage() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyCount)
            load(queue: &queue, keyPath: \Self.accountCount)
            load(queue: &queue, keyPath: \Self.assetCount)
            load(queue: &queue, keyPath: \Self.stockCount)
            load(queue: &queue, keyPath: \Self.categoryCount)
            load(queue: &queue, keyPath: \Self.payeeCount)
            load(queue: &queue, keyPath: \Self.transactionCount)
            load(queue: &queue, keyPath: \Self.scheduledCount)
            return await allOk(queue: queue)
        }
        manageCount = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadManege() {
        currencyCount.unload()
        accountCount.unload()
        assetCount.unload()
        stockCount.unload()
        categoryCount.unload()
        payeeCount.unload()
        transactionCount.unload()
        scheduledCount.unload()
    }

    func loadCurrencyList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyDict)
            load(queue: &queue, keyPath: \Self.currencyOrder)
            load(queue: &queue, keyPath: \Self.currencyUsed)
            return await allOk(queue: queue)
        }
        currencyList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadCurrencyList() {
        currencyDict.unload()
        currencyOrder.unload()
        currencyUsed.unload()
        currencyList.state = .idle
    }

    func loadAccountList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.accountDict)
            load(queue: &queue, keyPath: \Self.accountOrder)
            load(queue: &queue, keyPath: \Self.accountUsed)
            return await allOk(queue: queue)
        }
        await MainActor.run {
            accountList.state = queueOk ? .ready(()) : .error("Cannot load data.")
        }
        log.debug("DEBUG: RepositoryViewModel.loadAccountList(): \(queueOk)")
        if case .ready(_) = accountDict.state {
            log.debug("DEBUG: RepositoryViewModel.loadAccountList(): dataById=.ready")
        }
    }

    func unloadAccountList() {
        accountDict.unload()
        accountOrder.unload()
        accountUsed.unload()
        accountList.state = .idle
    }

    func loadAssetList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.assetDict)
            load(queue: &queue, keyPath: \Self.assetOrder)
            load(queue: &queue, keyPath: \Self.assetUsed)
            return await allOk(queue: queue)
        }
        assetList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadAssetList() {
        assetDict.unload()
        assetOrder.unload()
        assetUsed.unload()
        assetList.state = .idle
    }

    func loadStockList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.stockDict)
            load(queue: &queue, keyPath: \Self.stockOrder)
            load(queue: &queue, keyPath: \Self.stockUsed)
            return await allOk(queue: queue)
        }
        stockList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadStockList() {
        stockDict.unload()
        stockOrder.unload()
        stockUsed.unload()
        stockList.state = .idle
    }

    func loadPayeeList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeDict)
            load(queue: &queue, keyPath: \Self.payeeOrder)
            load(queue: &queue, keyPath: \Self.payeeUsed)
            return await allOk(queue: queue)
        }
        payeeList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadPayeeList() {
        payeeDict.unload()
        payeeOrder.unload()
        payeeUsed.unload()
        payeeList.state = .idle
    }

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
