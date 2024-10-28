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

    typealias I = InfotableRepository

    typealias U = CurrencyRepository
    typealias UH = CurrencyHistoryRepository
    @Published var currencyList  : CurrencyList  = .init()
    @Published var currencyGroup : CurrencyGroup = .init()

    typealias A = AccountRepository
    @Published var accountList  : AccountList  = .init()
    @Published var accountGroup : AccountGroup = .init()

    typealias E = AssetRepository
    @Published var assetList  : AssetList  = .init()
    @Published var assetGroup : AssetGroup = .init()

    typealias S = StockRepository
    typealias SH = StockHistoryRepository
    @Published var stockList  : StockList  = .init()
    @Published var stockGroup : StockGroup = .init()

    typealias C = CategoryRepository
    @Published var categoryList  : CategoryList  = .init()
    @Published var categoryGroup : CategoryGroup = .init()

    typealias P = PayeeRepository
    @Published var payeeList  : PayeeList  = .init()
    @Published var payeeGroup : PayeeGroup = .init()

    typealias T = TransactionRepository
    typealias TS = TransactionSplitRepository
    typealias TL = TransactionLinkRepository
    typealias TH = TransactionShareRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount : LoadMainCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    typealias RS = ScheduledSplitRepository
    @Published var scheduledCount : LoadMainCount<R> = .init()

    typealias G = TagRepository
    typealias GL = TagLinkRepository
    typealias F = FieldRepository
    typealias FD = FieldContentRepository
    typealias AX = AttachmentRepository
    typealias Y = BudgetYearRepository
    typealias B = BudgetTableRepository
    typealias O = ReportRepository

    init(env: EnvironmentManager) {
        self.env = env
    }
}

extension ViewModel {
    func load<RepositoryLoadType: LoadFetchProtocol>(
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].fetchValue(env: self.env)
        if let value {
            self[keyPath: keyPath].value = value
        }
        self[keyPath: keyPath].state.loaded(ok: value != nil)
        return value != nil
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].evalValue(env: self.env, vm: self)
        if let value {
            self[keyPath: keyPath].value = value
        }
        self[keyPath: keyPath].state.loaded(ok: value != nil)
        return value != nil
    }

    func load<RepositoryLoadType: LoadFetchProtocol>(
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].fetchValue(env: self.env)
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: value != nil)
            }
            return value != nil
        }
        return true
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].evalValue(env: self.env, vm: self)
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: value != nil)
            }
            return value != nil
        }
        return true
    }

    func taskGroupOk(_ taskGroup: TaskGroup<Bool>, _ ok: Bool = true) async -> Bool {
        var ok = ok
        for await taskOk in taskGroup {
            if !taskOk { ok = false }
        }
        return ok
    }
}

extension ViewModel {
    func loadList<ListType: ListProtocol>(_ list: ListType) async {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { async let _ = loadCurrencyList() }
        else if MainRepository.self == A.self { async let _ = loadAccountList() }
        else if MainRepository.self == E.self { async let _ = loadAssetList() }
        else if MainRepository.self == S.self { async let _ = loadStockList() }
        else if MainRepository.self == C.self { async let _ = loadCategoryList() }
        else if MainRepository.self == P.self { async let _ = loadPayeeList() }
    }

    func unloadList<ListType: ListProtocol>(_ list: ListType) {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { unloadCurrencyList() }
        else if MainRepository.self == A.self { unloadAccountList() }
        else if MainRepository.self == E.self { unloadAssetList() }
        else if MainRepository.self == S.self { unloadStockList() }
        else if MainRepository.self == C.self { unloadCategoryList() }
        else if MainRepository.self == P.self { unloadPayeeList() }
    }

    func loadList() async {
        async let _ = loadManage()
        async let _ = loadCurrencyList()
        async let _ = loadAccountList()
        async let _ = loadAssetList()
        async let _ = loadStockList()
        async let _ = loadCategoryList()
        async let _ = loadPayeeList()
    }

    func unloadList() {
        unloadManege()
        unloadCurrencyList()
        unloadAccountList()
        unloadAssetList()
        unloadStockList()
        unloadCategoryList()
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
        else if MainRepository.self == C.self { loadCategoryGroup(choice: choice as! CategoryGroupChoice) }
        else if MainRepository.self == P.self { loadPayeeGroup(choice: choice as! PayeeGroupChoice) }
    }
    
    func unloadGroup<GroupType: GroupProtocol>(_ group: GroupType) {
        typealias MainRepository = GroupType.MainRepository
        /**/ if MainRepository.self == U.self { unloadCurrencyGroup() }
        else if MainRepository.self == A.self { unloadAccountGroup() }
        else if MainRepository.self == E.self { unloadAssetGroup() }
        else if MainRepository.self == S.self { unloadStockGroup() }
        else if MainRepository.self == C.self { unloadCategoryGroup() }
        else if MainRepository.self == P.self { unloadPayeeGroup() }
    }

    func unloadGroup() {
        unloadCurrencyGroup()
        unloadAccountGroup()
        unloadAssetGroup()
        unloadStockGroup()
        unloadCategoryGroup()
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
        } else if MainData.self == C.RepositoryData.self {
            async let _ = reloadCategoryList(oldData as! CategoryData?, newData as! CategoryData?)
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
        } else if GroupType.MainRepository.self == C.self {
            searchCategoryGroup(search: search as! CategorySearch, expand: expand)
        } else if GroupType.MainRepository.self == P.self {
            searchPayeeGroup(search: search as! PayeeSearch, expand: expand)
        }
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
        } else if let data = data as? CategoryData {
            // TODO: name -> path
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
