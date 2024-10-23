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
    @Published var currencyCount : RepositoryLoadMainCount<U> = .init()
    @Published var currencyData  : RepositoryLoadMainData<U>  = .init()
    @Published var currencyName  : RepositoryLoadMainName<U>  = .init { $0[U.col_name] }
    @Published var currencyOrder : RepositoryLoadMainOrder<U> = .init(order: [U.col_name])
    @Published var currencyUsed  : RepositoryLoadMainUsed<U>  = .init()
    @Published var currencyList  : RepositoryLoadList<U>      = .init()
    @Published var currencyGroup : CurrencyGroup              = .init()

    typealias A = AccountRepository
    @Published var accountCount : RepositoryLoadMainCount<A> = .init()
    @Published var accountData  : RepositoryLoadMainData<A>  = .init()
    @Published var accountName  : RepositoryLoadMainName<A>  = .init { $0[A.col_name] }
    @Published var accountOrder : RepositoryLoadMainOrder<A> = .init(order: [A.col_name])
    @Published var accountUsed  : RepositoryLoadMainUsed<A>  = .init()
    @Published var accountAtt   : RepositoryLoadAuxAtt<A>    = .init()
    @Published var accountList  : RepositoryLoadList<A>      = .init()
    @Published var accountGroup : AccountGroup               = .init()

    typealias E = AssetRepository
    @Published var assetCount : RepositoryLoadMainCount<E> = .init()
    @Published var assetData  : RepositoryLoadMainData<E>  = .init()
    @Published var assetOrder : RepositoryLoadMainOrder<E> = .init(order: [E.col_name])
    @Published var assetUsed  : RepositoryLoadMainUsed<E>  = .init()
    @Published var assetAtt   : RepositoryLoadAuxAtt<E>    = .init()
    @Published var assetList  : RepositoryLoadList<E>      = .init()
    @Published var assetGroup : AssetGroup                 = .init()

    typealias S = StockRepository
    @Published var stockCount : RepositoryLoadMainCount<S> = .init()
    @Published var stockData  : RepositoryLoadMainData<S>  = .init()
    @Published var stockOrder : RepositoryLoadMainOrder<S> = .init(order: [S.col_name])
    @Published var stockUsed  : RepositoryLoadMainUsed<S>  = .init()
    @Published var stockAtt   : RepositoryLoadAuxAtt<S>    = .init()
    @Published var stockList  : RepositoryLoadList<S>      = .init()
    @Published var stockGroup : StockGroup                 = .init()

    typealias C = CategoryRepository
    @Published var categoryCount : RepositoryLoadMainCount<C> = .init()

    typealias P = PayeeRepository
    @Published var payeeCount : RepositoryLoadMainCount<P> = .init()
    @Published var payeeData  : RepositoryLoadMainData<P>  = .init()
    @Published var payeeName  : RepositoryLoadMainName<P>  = .init { $0[P.col_name] }
    @Published var payeeOrder : RepositoryLoadMainOrder<P> = .init(order: [P.col_name])
    @Published var payeeUsed  : RepositoryLoadMainUsed<P>  = .init()
    @Published var payeeAtt   : RepositoryLoadAuxAtt<P>    = .init()
    @Published var payeeList  : RepositoryLoadList<P>      = .init()
    @Published var payeeGroup : PayeeGroup                 = .init()

    typealias T = TransactionRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount : RepositoryLoadMainCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    @Published var scheduledCount : RepositoryLoadMainCount<R> = .init()

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
    func loadList<MainRepository>(for list: RepositoryLoadList<MainRepository>) async {
        /**/ if MainRepository.self == U.self { async let _ = loadCurrencyList() }
        else if MainRepository.self == A.self { async let _ = loadAccountList() }
        else if MainRepository.self == E.self { async let _ = loadAssetList() }
        else if MainRepository.self == S.self { async let _ = loadStockList() }
        else if MainRepository.self == P.self { async let _ = loadPayeeList() }
    }

    func unloadList<MainRepository>(for list: RepositoryLoadList<MainRepository>) {
        /**/ if MainRepository.self == U.self { unloadCurrencyList() }
        else if MainRepository.self == A.self { unloadAccountList() }
        else if MainRepository.self == E.self { unloadAssetList() }
        else if MainRepository.self == S.self { unloadStockList() }
        else if MainRepository.self == P.self { unloadPayeeList() }
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
    ) where GroupChoiceType == GroupType.GroupChoice
    {
        if GroupType.MainRepository.self == U.self {
            //            let _ = loadCurrencyGroup(env: env, choice: choice as! CurrencyGroupChoice)
        } else if GroupType.MainRepository.self == A.self {
            let _ = loadAccountGroup(env: env, choice: choice as! AccountGroupChoice)
        } else if GroupType.MainRepository.self == E.self {
            //            let _ = loadAssetGroup(env: env, choice: choice as! AssetGroupChoice)
        } else if GroupType.MainRepository.self == S.self {
            //            let _ = loadStockGroup(env: env, choice: choice as! StockGroupChoice)
        } else if GroupType.MainRepository.self == P.self {
            //            let _ = loadPayeeGroup(env: env, choice: choice as! PayeeGroupChoice)
        }
    }

    func unloadGroup<GroupType: RepositoryLoadGroupProtocol>(
        for group: GroupType
    ) {
        /**/ if GroupType.MainRepository.self == U.self { let _ = unloadCurrencyGroup() }
        else if GroupType.MainRepository.self == A.self { let _ = unloadAccountGroup() }
        else if GroupType.MainRepository.self == E.self { let _ = unloadAssetGroup() }
        else if GroupType.MainRepository.self == S.self { let _ = unloadStockGroup() }
        else if GroupType.MainRepository.self == P.self { let _ = unloadPayeeGroup() }
    }

    func unloadGroup() {
        let _ = unloadCurrencyGroup()
        let _ = unloadAccountGroup()
        let _ = unloadAssetGroup()
        let _ = unloadStockGroup()
        let _ = unloadPayeeGroup()
    }

    func reload<MainData: DataProtocol>(
        _ oldData: MainData?,
        _ newData: MainData?
    ) async {
        if MainData.self == U.RepositoryData.self {
        } else if MainData.self == A.RepositoryData.self {
            await reloadAccount(oldData as! AccountData?, newData as! AccountData?)
        } else if MainData.self == E.RepositoryData.self {
        } else if MainData.self == S.RepositoryData.self {
        } else if MainData.self == P.RepositoryData.self {
        }
    }

    func unloadAll() {
        unloadGroup()
        unloadList()
    }
}

extension RepositoryViewModel {
    func searchGroup<GroupType: RepositoryLoadGroupProtocol, SearchType: RepositorySearchProtocol>(
        for group: GroupType,
        search: SearchType,
        expand: Bool = false
    ) where GroupType.MainRepository.RepositoryData == SearchType.MainData
    {
        if GroupType.MainRepository.self == U.self {
//            let _ = searchCurrencyGroup(search: search as! CurrencySearch, expand: expand)
        } else if GroupType.MainRepository.self == A.self {
            let _ = searchAccountGroup(search: search as! AccountSearch, expand: expand)
        } else if GroupType.MainRepository.self == E.self {
//            let _ = searchAssetGroup(search: search as! AssetSearch, expand: expand)
        } else if GroupType.MainRepository.self == S.self {
//            let _ = searchStockGroup(search: search as! StockSearch, expand: expand)
        } else if GroupType.MainRepository.self == P.self {
//            let _ = searchPayeeGroup(search: search as! PayeeSearch, expand: expand)
        }
    }
}

/*
extension OldRepositoryViewModelProtocol {
    func preloaded(env: EnvironmentManager, group: GroupChoiceType) -> Self {
        Task {
            await loadData(env: env)
            loadGroup(env: env, group: group)
            searchGroup()
        }
        return self
    }
    func dataIsVisible(_ dataId: DataId) -> Bool {
        search.match(dataById[dataId]!)
    }
}
*/
