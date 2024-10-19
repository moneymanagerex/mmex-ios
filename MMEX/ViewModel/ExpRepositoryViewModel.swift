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

protocol ExpRepositoryLoadProtocol {
    associatedtype DataType: Copyable
    var state: ExpRepositoryLoadState<DataType> { get set }
    func load(env: EnvironmentManager) -> DataType?
    mutating func unload()
}

extension ExpRepositoryLoadProtocol {
    mutating func unload() {
        self.state = .idle
    }
}

struct ExpRepositoryLoadCount<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    typealias DataType = Int

    let table: SQLite.Table
    var state: ExpRepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.count(from: self.table)
    }
}

struct ExpRepositoryLoadDataById<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    typealias RepositoryData = RepositoryType.RepositoryData
    typealias DataType = [DataId: RepositoryData]

    let table: SQLite.Table
    var state: ExpRepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = table
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.selectById(from: self.table)
    }
}

struct ExpRepositoryLoadOrder<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    typealias DataType = [DataId]
    let table: SQLite.Table
    var state: ExpRepositoryLoadState<DataType> = .init()

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

struct ExpRepositoryLoadUsed<RepositoryType: RepositoryProtocol>: ExpRepositoryLoadProtocol {
    typealias DataType = Set<DataId>
    let table: SQLite.Table
    var state: ExpRepositoryLoadState<DataType> = .init()

    init(table: SQLite.Table = RepositoryType.table) {
        self.table = RepositoryType.filterUsed(table)
    }

    func load(env: EnvironmentManager) -> DataType? {
        RepositoryType(env)?.selectId(from: self.table).map { Set($0) }
    }
}

@MainActor
class ExpRepositoryViewModel: ObservableObject {
    let env: EnvironmentManager

    typealias U = CurrencyRepository
    @Published var currencyCount    : ExpRepositoryLoadCount<U> = .init()
    @Published var currencyDataById : ExpRepositoryLoadDataById<U> = .init()
    @Published var currencyOrder    : ExpRepositoryLoadOrder<U> = .init(expr: [C.col_name])
    @Published var currencyUsed     : ExpRepositoryLoadUsed<U> = .init()
    @Published var currencyList     : ExpRepositoryLoadState<Void> = .init()

    typealias A = AccountRepository
    @Published var accountCount    : ExpRepositoryLoadCount<A> = .init()
    @Published var accountDataById : ExpRepositoryLoadDataById<A> = .init()
    @Published var accountOrder    : ExpRepositoryLoadOrder<A> = .init(expr: [A.col_name])
    @Published var accountUsed     : ExpRepositoryLoadUsed<A> = .init()
    //@Published var accountGroup    : ExpRepositoryLoadGroup<AccountGroup> = .init()
    @Published var accountList     : ExpRepositoryLoadState<Void> = .init()

    typealias E = AssetRepository
    @Published var assetCount    : ExpRepositoryLoadCount<E> = .init()
    
    typealias S = StockRepository
    @Published var stockCount    : ExpRepositoryLoadCount<S> = .init()
    
    typealias C = CategoryRepository
    @Published var categoryCount    : ExpRepositoryLoadCount<C> = .init()

    typealias P = PayeeRepository
    @Published var payeeCount    : ExpRepositoryLoadCount<P> = .init()

    typealias T = TransactionRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount    : ExpRepositoryLoadCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    @Published var scheduledCount    : ExpRepositoryLoadCount<R> = .init()

    //var currencyName : ExpRepositoryLoad<[(DataId, String)]>     = .init([])
    //var accountAttachmentCount : ExpRepositoryLoad<[DataId: Int]>         = .init([:])
    //var currencyGroup : ExpRepositoryGroup<CurrencyGroup> = .init()
    //var accountGroup  : ExpRepositoryGroup<AccountGroup>  = .init()
    
    @Published var manageCount: ExpRepositoryLoadState<Void> = .init()
    
    init(env: EnvironmentManager) {
        self.env = env
    }
}

extension ExpRepositoryViewModel {
    func load<ExpRepositoryLoadType>(
        queue: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ExpRepositoryViewModel, ExpRepositoryLoadType>
    ) where ExpRepositoryLoadType: ExpRepositoryLoadProtocol {
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

extension ExpRepositoryViewModel {
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
            load(queue: &queue, keyPath: \Self.currencyDataById)
            load(queue: &queue, keyPath: \Self.currencyOrder)
            load(queue: &queue, keyPath: \Self.currencyUsed)
            return await allOk(queue: queue)
        }
        currencyList = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadCurrencyList() {
        currencyDataById.unload()
        currencyOrder.unload()
        currencyUsed.unload()
        currencyList = .idle
    }

    func loadAccountList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.accountDataById)
            load(queue: &queue, keyPath: \Self.accountOrder)
            load(queue: &queue, keyPath: \Self.accountUsed)
            return await allOk(queue: queue)
        }
        accountList = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadAccountList() {
        accountDataById.unload()
        accountOrder.unload()
        accountUsed.unload()
        accountList = .idle
    }

    func unloadAll() {
        unloadManege()
        unloadCurrencyList()
        unloadAccountList()
    }
}
