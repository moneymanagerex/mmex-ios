//
//  AccountListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountGroup: String, RepositoryGroupProtocol {
    case all      = "All"
    case used     = "Used"
    case favorite = "Favorite"
    case type     = "Type"
    case currency = "Currency"
    case status   = "Status"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AccountSearch: RepositorySearchProtocol {
    var area: [RepositorySearchArea<AccountData>] = [
        ("Name",  true,  [ {$0.name} ]),
        ("Notes", false, [ {$0.notes} ]),
        ("Other", false, [ {$0.num}, {$0.heldAt}, {$0.website}, {$0.contactInfo}, {$0.accessInfo} ]),
    ]
    var key: String = ""
}

@MainActor
class AccountViewModel: RepositoryViewModelProtocol {
    typealias RepositoryData   = AccountData
    typealias RepositoryGroup  = AccountGroup
    typealias RepositorySearch = AccountSearch

    @Published var dataState: RepositoryLoadState = .idle
    var dataById: [DataId : RepositoryData] = [:]
    var usedId: Set<DataId> = []
    private var dataId: [DataId] = [] // sorted by name
    private(set) var currencyName: [(DataId, String)] = [] // sorted by name

    @Published var group = AccountGroup.defaultValue
    @Published var groupState: RepositoryLoadState = .idle
    @Published var groupDataId: [[DataId]] = []

    @Published var search = AccountSearch()
    @Published var groupIsVisible  : [Bool] = []
    @Published var groupIsExpanded : [Bool] = []

    static let newData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    static let groupUsed: [Bool] = [
        true, false
    ]

    static let groupType: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment
    ]

    var groupCurrency: [DataId] = []

    static let groupStatus: [AccountStatus] = [
        .open, .closed
    ]

    static let groupFavorite: [AccountFavorite] = [
        .boolTrue, .boolFalse
    ]

    func loadData(env: EnvironmentManager) async {
        log.trace("DEBUG: AccountViewModel.loadData(): main=\(Thread.isMainThread)")
        guard dataState == .idle else { return }
        dataState = .loading
        //log.debug("DEBUG: AccountViewModel.loadData(): dataState=\(self.dataState.rawValue)")
        //log.debug("DEBUG: AccountViewModel.loadData(): groupState=\(self.groupState.rawValue)")
        let allOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                let data: [DataId: RepositoryData]? = AccountRepository(env)?.selectById(
                    from: A.table
                )
                await MainActor.run { if let data { self.dataById = data } }
                return data != nil
            }
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                let data: [DataId]? = AccountRepository(env)?.selectId(
                    from: A.filterUsed(A.table)
                )
                await MainActor.run { if let data {
                    self.usedId = Set(data)
                } }
                return data != nil
            }
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                let data: [DataId]? = AccountRepository(env)?.selectId(
                    from: A.table.order(A.col_name)
                )
                await MainActor.run { if let data { self.dataId = data } }
                return data != nil
            }
            queue.addTask(priority: .background) {
                let data: [(DataId, String)]? = CurrencyRepository(env)?.loadName()
                await MainActor.run { if let data { self.currencyName = data } }
                return data != nil
            }

            var allOk = true
            for await taskOk in queue {
                if !taskOk { allOk = false }
            }
            return allOk
        }

        if allOk {
            dataState = .ready
            log.info("INFO: AccountViewModel.loadData(): main=\(Thread.isMainThread), \(self.dataById.count), \(self.dataId.count), \(self.currencyName.count)")
        } else {
            dataState = .error
            log.error("ERROR: AccountViewModel.loadData(): main=\(Thread.isMainThread)")
        }
    }

    func unloadData() {
        log.trace("DEBUG: AccountViewModel.unloadData(): main=\(Thread.isMainThread)")
        if dataState == .idle { return }
        if groupState != .idle { unloadGroup() }
        dataState = .idle
        dataById.removeAll()
        dataId = []
        currencyName = []
    }

    func addGroup(_ dataId: [DataId], _ isVisible: Bool, _ isExpanded: Bool) {
        groupDataId.append(dataId)
        groupIsVisible.append(isVisible)
        groupIsExpanded.append(isExpanded)
    }

    func loadGroup(env: EnvironmentManager, group: AccountGroup) {
        log.trace("DEBUG: AccountViewModel.loadGroup(\(self.group.rawValue)): main=\(Thread.isMainThread)")
        guard dataState == .ready && groupState != .loading else { return }
        groupState = .loading
        self.group = group
        groupCurrency = []
        groupDataId = []
        groupIsVisible.removeAll(keepingCapacity: true)
        groupIsExpanded.removeAll(keepingCapacity: true)
        switch group {
        case .all:
            addGroup(dataId, true, true)
        case .used:
            let dict = Dictionary(grouping: dataId) { usedId.contains($0) }
            for g in Self.groupUsed {
                addGroup(dict[g] ?? [], true, g)
            }
        case .favorite:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.favoriteAcct }
            for g in Self.groupFavorite {
                addGroup(dict[g] ?? [], true, g == .boolTrue)
            }
        case .type:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.type }
            for g in Self.groupType {
                addGroup(dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.currencyId }
            groupCurrency = env.currencyCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in groupCurrency {
                addGroup(dict[g] ?? [], dict[g] != nil, true)
            }
        case .status:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.status }
            for g in Self.groupStatus {
                addGroup(dict[g] ?? [], true, g == .open)
            }
        }
        groupState = .ready
    }

    func groupIsVisible(_ g: Int) -> Bool {
        if search.isEmpty {
            return switch group {
            case .type, .currency: !groupDataId[g].isEmpty
            default: true
            }
        }
        return groupDataId[g].first(where: { dataIsVisible($0) }) != nil
    }

    /*
    func loadCurrencyName() {
        currencyName = []
        guard let repository = CurrencyRepository(env) else { return }
        DispatchQueue.global(qos: .background).async {
            let id_name = repository.loadName()
            DispatchQueue.main.async {
                self.currencyName = id_name
            }
        }
    }

    func loadDataById() {
        dataById = [:]
        guard let repository = AccountRepository(env) else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dataById: [DataId: RepositoryData] = repository.dict(
                from: A.table.order(A.col_name)
            )
            DispatchQueue.main.async {
                self.dataById = dataById
            }
        }
    }

    func loadDataId() {
        dataId = []
        guard let repository = AccountRepository(env) else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dataId: [DataId] = repository.select(
                from: A.table.order(A.col_name),
                with: A.fetchId
            )
            DispatchQueue.main.async {
                self.dataId = dataId
            }
        }
    }
*/
}
