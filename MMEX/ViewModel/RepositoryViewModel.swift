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
    @Published var currencyDataCount : RepositoryLoadDataCount<U> = .init()
    @Published var currencyDataDict  : RepositoryLoadDataDict<U>  = .init()
    @Published var currencyDataName  : RepositoryLoadDataName<U>  = .init { $0[U.col_name] }
    @Published var currencyDataOrder : RepositoryLoadDataOrder<U> = .init(expr: [U.col_name])
    @Published var currencyDataUsed  : RepositoryLoadDataUsed<U>  = .init()
    @Published var currencyList      : RepositoryLoadList<U>      = .init()
    @Published var currencyGroup     : CurrencyGroup              = .init()

    typealias A = AccountRepository
    @Published var accountDataCount : RepositoryLoadDataCount<A> = .init()
    @Published var accountDataDict  : RepositoryLoadDataDict<A>  = .init()
    @Published var accountDataName  : RepositoryLoadDataName<A>  = .init { $0[A.col_name] }
    @Published var accountDataOrder : RepositoryLoadDataOrder<A> = .init(expr: [A.col_name])
    @Published var accountDataUsed  : RepositoryLoadDataUsed<A>  = .init()
    @Published var accountList      : RepositoryLoadList<A>      = .init()
    @Published var accountGroup     : AccountGroup               = .init()

    typealias E = AssetRepository
    @Published var assetDataCount : RepositoryLoadDataCount<E> = .init()
    @Published var assetDataDict  : RepositoryLoadDataDict<E>  = .init()
    @Published var assetDataOrder : RepositoryLoadDataOrder<E> = .init(expr: [E.col_name])
    @Published var assetDataUsed  : RepositoryLoadDataUsed<E>  = .init()
    @Published var assetList      : RepositoryLoadList<E>      = .init()
    @Published var assetGroup     : AssetGroup                 = .init()

    typealias S = StockRepository
    @Published var stockDataCount : RepositoryLoadDataCount<S> = .init()
    @Published var stockDataDict  : RepositoryLoadDataDict<S>  = .init()
    @Published var stockDataOrder : RepositoryLoadDataOrder<S> = .init(expr: [S.col_name])
    @Published var stockDataUsed  : RepositoryLoadDataUsed<S>  = .init()
    @Published var stockList      : RepositoryLoadList<S>      = .init()
    @Published var stockGroup     : StockGroup                 = .init()

    typealias C = CategoryRepository
    @Published var categoryDataCount : RepositoryLoadDataCount<C> = .init()

    typealias P = PayeeRepository
    @Published var payeeDataCount : RepositoryLoadDataCount<P> = .init()
    @Published var payeeDataDict  : RepositoryLoadDataDict<P>  = .init()
    @Published var payeeDataName  : RepositoryLoadDataName<P>  = .init { $0[P.col_name] }
    @Published var payeeDataOrder : RepositoryLoadDataOrder<P> = .init(expr: [P.col_name])
    @Published var payeeDataUsed  : RepositoryLoadDataUsed<P>  = .init()
    @Published var payeeList      : RepositoryLoadList<P>      = .init()
    @Published var payeeGroup     : PayeeGroup                 = .init()

    typealias T = TransactionRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionDataCount : RepositoryLoadDataCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    @Published var scheduledDataCount : RepositoryLoadDataCount<R> = .init()

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
    func loadList<RepositoryType>(for data: RepositoryLoadList<RepositoryType>) async {
        /**/ if RepositoryType.self == U.self { async let _ = loadCurrencyList() }
        else if RepositoryType.self == A.self { async let _ = loadAccountList() }
        else if RepositoryType.self == E.self { async let _ = loadAssetList() }
        else if RepositoryType.self == S.self { async let _ = loadStockList() }
        else if RepositoryType.self == P.self { async let _ = loadPayeeList() }
    }

    func unloadList<RepositoryType>(for data: RepositoryLoadList<RepositoryType>) {
        /**/ if RepositoryType.self == U.self { unloadCurrencyList() }
        else if RepositoryType.self == A.self { unloadAccountList() }
        else if RepositoryType.self == E.self { unloadAssetList() }
        else if RepositoryType.self == S.self { unloadStockList() }
        else if RepositoryType.self == P.self { unloadPayeeList() }
    }

    func loadList() async {
        async let _ = loadManage()
        async let _ = loadCurrencyList()
        async let _ = loadAccountList()
        async let _ = loadAssetList()
        async let _ = loadStockList()
        async let _ = loadPayeeList()
    }

    func unloadList() {
        unloadManege()
        unloadCurrencyList()
        unloadAccountList()
        unloadAssetList()
        unloadStockList()
        unloadPayeeList()
    }
}

extension RepositoryViewModel {
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

    func unloadGroup() {
        let _ = unloadCurrencyGroup()
        let _ = unloadAccountGroup()
        let _ = unloadAssetGroup()
        let _ = unloadStockGroup()
        let _ = unloadPayeeGroup()
    }

    func unloadAll() {
        unloadList()
        unloadGroup()
    }
}

extension RepositoryViewModel {
    func searchGroup<GroupType: RepositoryLoadGroupProtocol, SearchType: RepositorySearchProtocol>(
        for group: GroupType,
        search: SearchType,
        expand: Bool = false
    ) where GroupType.RepositoryType.RepositoryData == SearchType.RepositoryData
    {
        if GroupType.RepositoryType.self == U.self {
//            let _ = searchCurrencyGroup(search: search as! CurrencySearch, expand: expand)
        } else if GroupType.RepositoryType.self == A.self {
            let _ = searchAccountGroup(search: search as! AccountSearch, expand: expand)
        } else if GroupType.RepositoryType.self == E.self {
//            let _ = searchAssetGroup(search: search as! AssetSearch, expand: expand)
        } else if GroupType.RepositoryType.self == S.self {
//            let _ = searchStockGroup(search: search as! StockSearch, expand: expand)
        } else if GroupType.RepositoryType.self == P.self {
//            let _ = searchPayeeGroup(search: search as! PayeeSearch, expand: expand)
        }
    }
}
