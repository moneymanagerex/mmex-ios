//
//  ViewModel.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

@MainActor
class ViewModel: ObservableObject {
    let env: EnvironmentManager

    @Published var manageList: LoadState = .init()

    typealias U = CurrencyRepository
    @Published var currencyList  : CurrencyList  = .init()
    @Published var currencyGroup : CurrencyGroup = .init()

    typealias A = AccountRepository
    @Published var accountList  : AccountList  = .init()
    @Published var accountGroup : AccountGroup = .init()

    typealias E = AssetRepository
    @Published var assetList  : AssetList  = .init()
    @Published var assetGroup : AssetGroup = .init()

    typealias S = StockRepository
    @Published var stockList  : StockList  = .init()
    @Published var stockGroup : StockGroup = .init()

    typealias C = CategoryRepository
    @Published var categoryCount : LoadMainCount<C> = .init()

    typealias P = PayeeRepository
    @Published var payeeList  : PayeeList  = .init()
    @Published var payeeGroup : PayeeGroup = .init()

    typealias T = TransactionRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount : LoadMainCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    @Published var scheduledCount : LoadMainCount<R> = .init()

    init(env: EnvironmentManager) {
        self.env = env
    }
}

extension ViewModel {
    func load<RepositoryLoadType>(
        queue: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) where RepositoryLoadType: LoadProtocol {
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

extension ViewModel {
    func loadList<ListType: ListProtocol>(_ list: ListType) async {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { async let _ = loadCurrencyList() }
        else if MainRepository.self == A.self { async let _ = loadAccountList() }
        else if MainRepository.self == E.self { async let _ = loadAssetList() }
        else if MainRepository.self == S.self { async let _ = loadStockList() }
        else if MainRepository.self == P.self { async let _ = loadPayeeList() }
    }

    func unloadList<ListType: ListProtocol>(_ list: ListType) {
        typealias MainRepository = ListType.MainRepository
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

extension ViewModel {
    func loadGroup<GroupType: GroupProtocol>(
        _ group: GroupType,
        choice: GroupType.GroupChoice
    ) {
        typealias MainRepository = GroupType.MainRepository
        /**/ if MainRepository.self == U.self { loadCurrencyGroup(choice: choice as! CurrencyGroupChoice) }
        else if MainRepository.self == A.self { loadAccountGroup(choice: choice as! AccountGroupChoice) }
        else if MainRepository.self == E.self { loadAssetGroup(choice: choice as! AssetGroupChoice) }
        else if MainRepository.self == S.self { loadStockGroup(choice: choice as! StockGroupChoice) }
        else if MainRepository.self == P.self { loadPayeeGroup(choice: choice as! PayeeGroupChoice) }
    }
    
    func unloadGroup<GroupType: GroupProtocol>(_ group: GroupType) {
        typealias MainRepository = GroupType.MainRepository
        /**/ if MainRepository.self == U.self { unloadCurrencyGroup() }
        else if MainRepository.self == A.self { unloadAccountGroup() }
        else if MainRepository.self == E.self { unloadAssetGroup() }
        else if MainRepository.self == S.self { unloadStockGroup() }
        else if MainRepository.self == P.self { unloadPayeeGroup() }
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

extension ViewModel {
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

extension ViewModel {
    func searchGroup<GroupType: GroupProtocol, SearchType: SearchProtocol>(
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

extension ViewModel {
    func isUsed<DataType: DataProtocol>(_ data: DataType) -> Bool? {
        if DataType.self == U.RepositoryData.self {
            return currencyList.used.state == .ready ? currencyList.used.value.contains(data.id) : nil
        } else if DataType.self == A.RepositoryData.self {
            return accountList.used.state == .ready ? accountList.used.value.contains(data.id) : nil
        } else if DataType.self == E.RepositoryData.self {
            return assetList.used.state == .ready ? assetList.used.value.contains(data.id) : nil
        } else if DataType.self == S.RepositoryData.self {
            return stockList.used.state == .ready ? stockList.used.value.contains(data.id) : nil
        } else if DataType.self == P.RepositoryData.self {
            return payeeList.used.state == .ready ? payeeList.used.value.contains(data.id) : nil
        }
        return nil
    }

    func update<DataType: DataProtocol>(_ data: inout DataType) -> String? {
        if var data = data as? CurrencyData {
            return updateCurrency(&data)
        } else if var data = data as? AccountData {
            return updateAccount(&data)
        } else if var data = data as? AssetData {
            return updateAsset(&data)
        } else if var data = data as? StockData {
            return updateStock(&data)
        } else if var data = data as? PayeeData {
            return updatePayee(&data)
        }
        return "* unknown data type"
    }

    func delete<DataType: DataProtocol>(_ data: DataType) -> String? {
        if let data = data as? CurrencyData {
            return deleteCurrency(data)
        } else if let data = data as? AccountData {
            return deleteAccount(data)
        } else if let data = data as? AssetData {
            return deleteAsset(data)
        } else if let data = data as? StockData {
            return deleteStock(data)
        } else if let data = data as? PayeeData {
            return deletePayee(data)
        }
        return "* unknown data type"
    }
}

extension ViewModel {
    func name<DataType: DataProtocol>(_ data: DataType) -> String {
        if let data = data as? CurrencyData {
            return data.name
        } else if let data = data as? AccountData {
            return data.name
        } else if let data = data as? AssetData {
            return data.name
        } else if let data = data as? StockData {
            return data.name
        } else if let data = data as? PayeeData {
            return data.name
        }
        return ""
    }

    func filename<DataType: DataProtocol>(_ data: DataType) -> String {
        return "\(name(data))_\(DataType.dataName.0)"
    }
}
