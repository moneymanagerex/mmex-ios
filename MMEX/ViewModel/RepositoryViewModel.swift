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

    @Published var manageCount: RepositoryLoadState = .init()

    typealias U = CurrencyRepository
    @Published var currencyCount : RepositoryLoadMainCount<U> = .init()
    @Published var currencyData  : RepositoryLoadMainData<U>  = .init()
    @Published var currencyName  : RepositoryLoadMainName<U>  = .init { $0[U.col_name] }
    @Published var currencyOrder : RepositoryLoadMainOrder<U> = .init(order: [U.col_name])
    @Published var currencyUsed  : RepositoryLoadMainUsed<U>  = .init()
    @Published var currencyList  : RepositoryLoadMainList<U>  = .init()
    @Published var currencyGroup : CurrencyGroup              = .init()

    typealias A = AccountRepository
    @Published var accountCount : RepositoryLoadMainCount<A> = .init()
    @Published var accountData  : RepositoryLoadMainData<A>  = .init()
    @Published var accountName  : RepositoryLoadMainName<A>  = .init { $0[A.col_name] }
    @Published var accountOrder : RepositoryLoadMainOrder<A> = .init(order: [A.col_name])
    @Published var accountUsed  : RepositoryLoadMainUsed<A>  = .init()
    @Published var accountAtt   : RepositoryLoadAuxAtt<A>    = .init()
    @Published var accountList  : RepositoryLoadMainList<A>  = .init()
    @Published var accountGroup : AccountGroup               = .init()

    typealias E = AssetRepository
    @Published var assetCount : RepositoryLoadMainCount<E> = .init()
    @Published var assetData  : RepositoryLoadMainData<E>  = .init()
    @Published var assetOrder : RepositoryLoadMainOrder<E> = .init(order: [E.col_name])
    @Published var assetUsed  : RepositoryLoadMainUsed<E>  = .init()
    @Published var assetAtt   : RepositoryLoadAuxAtt<E>    = .init()
    @Published var assetList  : RepositoryLoadMainList<E>  = .init()
    @Published var assetGroup : AssetGroup                 = .init()

    typealias S = StockRepository
    @Published var stockCount : RepositoryLoadMainCount<S> = .init()
    @Published var stockData  : RepositoryLoadMainData<S>  = .init()
    @Published var stockOrder : RepositoryLoadMainOrder<S> = .init(order: [S.col_name])
    @Published var stockUsed  : RepositoryLoadMainUsed<S>  = .init()
    @Published var stockAtt   : RepositoryLoadAuxAtt<S>    = .init()
    @Published var stockList  : RepositoryLoadMainList<S>  = .init()
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
    @Published var payeeList  : RepositoryLoadMainList<P>  = .init()
    @Published var payeeGroup : PayeeGroup                 = .init()

    typealias T = TransactionRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount : RepositoryLoadMainCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    @Published var scheduledCount : RepositoryLoadMainCount<R> = .init()

    init(env: EnvironmentManager) {
        self.env = env
    }
}

extension RepositoryViewModel {
    func load<RepositoryLoadType>(
        queue: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<RepositoryViewModel, RepositoryLoadType>
    ) where RepositoryLoadType: RepositoryLoadProtocol {
        guard self[keyPath: keyPath].state.loading() else { return }
        queue.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].fetch(env: self.env)
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: value != nil)
            }
            return value != nil
        }
    }

    func allOk(queue: TaskGroup<Bool>) async -> Bool {
        var allOk = true
        for await ok in queue {
            if !ok { allOk = false }
        }
        return allOk
    }
}

extension RepositoryViewModel {
    func loadList<MainRepository>(_ list: RepositoryLoadMainList<MainRepository>) async {
        /**/ if MainRepository.self == U.self { async let _ = loadCurrencyList() }
        else if MainRepository.self == A.self { async let _ = loadAccountList() }
        else if MainRepository.self == E.self { async let _ = loadAssetList() }
        else if MainRepository.self == S.self { async let _ = loadStockList() }
        else if MainRepository.self == P.self { async let _ = loadPayeeList() }
    }

    func unloadList<MainRepository>(_ list: RepositoryLoadMainList<MainRepository>) {
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
    func loadGroup<GroupType: RepositoryGroupProtocol, GroupChoice>(
        _ group: GroupType, choice: GroupChoice
    ) where GroupChoice == GroupType.GroupChoice {
        /**/ if GroupType.MainRepository.self == U.self { loadCurrencyGroup(choice: choice as! CurrencyGroupChoice) }
        else if GroupType.MainRepository.self == A.self { loadAccountGroup(choice: choice as! AccountGroupChoice) }
        else if GroupType.MainRepository.self == E.self { loadAssetGroup(choice: choice as! AssetGroupChoice) }
        else if GroupType.MainRepository.self == S.self { loadStockGroup(choice: choice as! StockGroupChoice) }
        else if GroupType.MainRepository.self == P.self { loadPayeeGroup(choice: choice as! PayeeGroupChoice) }
    }
    
    func unloadGroup<GroupType: RepositoryGroupProtocol>(_ group: GroupType) {
        /**/ if GroupType.MainRepository.self == U.self { unloadCurrencyGroup() }
        else if GroupType.MainRepository.self == A.self { unloadAccountGroup() }
        else if GroupType.MainRepository.self == E.self { unloadAssetGroup() }
        else if GroupType.MainRepository.self == S.self { unloadStockGroup() }
        else if GroupType.MainRepository.self == P.self { unloadPayeeGroup() }
    }

    func unloadGroup() {
        unloadCurrencyGroup()
        unloadAccountGroup()
        unloadAssetGroup()
        unloadStockGroup()
        unloadPayeeGroup()
    }

    func unloadAll() {
        unloadGroup()
        unloadList()
    }
}

extension RepositoryViewModel {
    func reloadList<MainData: DataProtocol>(_ oldData: MainData?, _ newData: MainData?) async {
        if MainData.self == U.RepositoryData.self {
            async let _ = reloadCurrencyList(oldData as! CurrencyData?, newData as! CurrencyData?)
        } else if MainData.self == A.RepositoryData.self {
            async let _ = reloadAccountList(oldData as! AccountData?, newData as! AccountData?)
        } else if MainData.self == E.RepositoryData.self {
            async let _ = reloadAssetList(oldData as! AssetData?, newData as! AssetData?)
        } else if MainData.self == S.RepositoryData.self {
            async let _ = reloadStockList(oldData as! StockData?, newData as! StockData?)
        } else if MainData.self == P.RepositoryData.self {
            async let _ = reloadPayeeList(oldData as! PayeeData?, newData as! PayeeData?)
        }
    }
}

extension RepositoryViewModel {
    func searchGroup<GroupType: RepositoryGroupProtocol, SearchType: RepositorySearchProtocol>(
        _ group: GroupType,
        search: SearchType,
        expand: Bool = false
    ) where GroupType.MainRepository.RepositoryData == SearchType.MainData {
        if GroupType.MainRepository.self == U.self {
            searchCurrencyGroup(search: search as! CurrencySearch)
        } else if GroupType.MainRepository.self == A.self {
            searchAccountGroup(search: search as! AccountSearch, expand: expand)
        } else if GroupType.MainRepository.self == E.self {
            searchAssetGroup(search: search as! AssetSearch, expand: expand)
        } else if GroupType.MainRepository.self == S.self {
            searchStockGroup(search: search as! StockSearch, expand: expand)
        } else if GroupType.MainRepository.self == P.self {
            searchPayeeGroup(search: search as! PayeeSearch, expand: expand)
        }
    }
}
