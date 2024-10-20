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
    @Published var currencyData  : RepositoryLoadData<U> = .init()
    @Published var currencyGroup : CurrencyGroup = .init()

    typealias A = AccountRepository
    @Published var accountCount : RepositoryLoadDataCount<A> = .init()
    @Published var accountDict  : RepositoryLoadDataDict<A> = .init()
    @Published var accountOrder : RepositoryLoadDataOrder<A> = .init(expr: [A.col_name])
    @Published var accountUsed  : RepositoryLoadDataUsed<A> = .init()
    @Published var accountData  : RepositoryLoadData<A> = .init()
    @Published var accountGroup : AccountGroup = .init()

    typealias E = AssetRepository
    @Published var assetCount : RepositoryLoadDataCount<E> = .init()
    @Published var assetDict  : RepositoryLoadDataDict<E> = .init()
    @Published var assetOrder : RepositoryLoadDataOrder<E> = .init(expr: [E.col_name])
    @Published var assetUsed  : RepositoryLoadDataUsed<E> = .init()
    @Published var assetData  : RepositoryLoadData<E> = .init()
    @Published var assetGroup : AssetGroup = .init()

    typealias S = StockRepository
    @Published var stockCount : RepositoryLoadDataCount<S> = .init()
    @Published var stockDict  : RepositoryLoadDataDict<S> = .init()
    @Published var stockOrder : RepositoryLoadDataOrder<S> = .init(expr: [S.col_name])
    @Published var stockUsed  : RepositoryLoadDataUsed<S> = .init()
    @Published var stockData  : RepositoryLoadData<S> = .init()
    @Published var stockGroup : StockGroup = .init()

    typealias C = CategoryRepository
    @Published var categoryCount    : RepositoryLoadDataCount<C> = .init()

    typealias P = PayeeRepository
    @Published var payeeCount : RepositoryLoadDataCount<P> = .init()
    @Published var payeeDict  : RepositoryLoadDataDict<P> = .init()
    @Published var payeeOrder : RepositoryLoadDataOrder<P> = .init(expr: [P.col_name])
    @Published var payeeUsed  : RepositoryLoadDataUsed<P> = .init()
    @Published var payeeData  : RepositoryLoadData<P> = .init()
    @Published var payeeGroup : PayeeGroup = .init()

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
        guard case .idle = self[keyPath: keyPath].state else { return }
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

    func allOk(queue: TaskGroup<Bool>) async -> Bool {
        var queueOk = true
        for await taskOk in queue {
            if !taskOk { queueOk = false }
        }
        return queueOk
    }
}

extension RepositoryViewModel {
    func loadData<RepositoryType>(for data: RepositoryLoadData<RepositoryType>) async {
        /**/ if RepositoryType.self == U.self { async let _ = loadCurrencyData() }
        else if RepositoryType.self == A.self { async let _ = loadAccountData() }
        else if RepositoryType.self == E.self { async let _ = loadAssetData() }
        else if RepositoryType.self == S.self { async let _ = loadStockData() }
        else if RepositoryType.self == P.self { async let _ = loadPayeeData() }
    }

    func unloadData<RepositoryType>(for data: RepositoryLoadData<RepositoryType>) {
        /**/ if RepositoryType.self == U.self { unloadCurrencyData() }
        else if RepositoryType.self == A.self { unloadAccountData() }
        else if RepositoryType.self == E.self { unloadAssetData() }
        else if RepositoryType.self == S.self { unloadStockData() }
        else if RepositoryType.self == P.self { unloadPayeeData() }
    }

    func loadGroup<GroupType: RepositoryLoadGroupProtocol, GroupChoiceType>(
        for group: GroupType,
        _ choice: GroupChoiceType
    ) where GroupChoiceType == GroupType.GroupChoiceType
    {
        if GroupType.RepositoryType.self == U.self {
//            let _ = loadCurrencyGroup(env: env, choice: choice as! CurrencyGroupChoice)
        } else if GroupType.RepositoryType.self == A.self {
            let _ = loadAccountGroup(env: env, choice: choice as! AccountGroupChoice)
        } else if GroupType.RepositoryType.self == E.self {
//            let _ = loadAssetGroup(env: env, choice: choice as! AssetGroupChoice)
        } else if GroupType.RepositoryType.self == S.self {
//            let _ = loadStockGroup(env: env, choice: choice as! StockGroupChoice)
        } else if GroupType.RepositoryType.self == P.self {
//            let _ = loadPayeeGroup(env: env, choice: choice as! PayeeGroupChoice)
        }
    }

    func unloadGroup<GroupType: RepositoryLoadGroupProtocol>(
        for group: GroupType
    ) {
        /**/ if GroupType.RepositoryType.self == U.self { let _ = unloadCurrencyGroup() }
        else if GroupType.RepositoryType.self == A.self { let _ = unloadAccountGroup() }
        else if GroupType.RepositoryType.self == E.self { let _ = unloadAssetGroup() }
        else if GroupType.RepositoryType.self == S.self { let _ = unloadStockGroup() }
        else if GroupType.RepositoryType.self == P.self { let _ = unloadPayeeGroup() }
    }

    func loadAll() async {
        async let _ = loadManage()
        async let _ = loadCurrencyData()
        async let _ = loadAccountData()
        async let _ = loadAssetData()
        async let _ = loadStockData()
        async let _ = loadPayeeData()
    }

    func unloadAll() {
        unloadManege()
        unloadCurrencyData()
        unloadAccountData()
        unloadAssetData()
        unloadStockData()
        unloadPayeeData()
    }
}
