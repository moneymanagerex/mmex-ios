//
//  AccountListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountGroupBy: String, RepositoryGroupByProtocol {
    case void       = "All" // No grouping by default
    case byType     = "By Type"
    case byCurrency = "By Currency"
    case byStatus   = "By Status"
    case byFavorite = "By Favorite"
    static let defaultValue = Self.void
}

struct AccountSearch: RepositorySearchProtocol {
    var mode = RepositorySearchMode.defaultValue
    var key: String = ""

    static var simpleConfig: [(String, Bool, (AccountData) -> [String])] = [
        ("Name",  true,  { [$0.name] }),
        ("Notes", false, { [$0.notes] }),
        ("other", false, { [$0.num, $0.heldAt, $0.website, $0.contactInfo, $0.accessInfo] }),
    ]
    var simpleIsActive = simpleConfig.map { $0.1 }

    var isEmpty: Bool { mode == .simple && key.isEmpty }
    func match(_ data: AccountData) -> Bool {
        if isEmpty { return true }

        // TODO: advanced search
        if mode != .simple { return true }

        for i in 0 ..< Self.simpleConfig.count {
            guard simpleIsActive[i] else { continue }
            if Self.simpleConfig[i].2(data).first(
                where: { $0.localizedCaseInsensitiveContains(key) }
            ) != nil {
                return true
            }
        }
        return false
    }
}

@MainActor
class AccountViewModel: RepositoryViewModelProtocol {
    typealias RepositoryData    = AccountData
    typealias RepositoryGroupBy = AccountGroupBy
    typealias RepositorySearch  = AccountSearch

    @Published var dataState: RepositoryLoadState = .idle
    var dataById: [DataId : RepositoryData] = [:]
    private var dataId: [DataId] = [] // sorted by name
    private(set) var currencyName: [(DataId, String)] = [] // sorted by name

    @Published var groupBy = AccountGroupBy.defaultValue
    @Published var groupState: RepositoryLoadState = .idle
    @Published var groupDataId: [[DataId]] = []

    @Published var search = AccountSearch()
    @Published var groupIsVisible  : [Bool] = []
    @Published var groupIsExpanded : [Bool] = []

    static let newData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    static let groupByType: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment
    ]

    var groupByCurrency: [DataId] = []

    static let groupByStatus: [AccountStatus] = [
        .open, .closed
    ]

    static let groupByFavorite: [AccountFavorite] = [
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
                let data: [DataId: RepositoryData]? = env.accountRepository?.selectById(
                    from: A.table.order(A.col_name)
                )
                await MainActor.run { if let data { self.dataById = data } }
                return data != nil
            }
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                let data: [DataId]? = env.accountRepository?.select(
                    from: A.table.order(A.col_name),
                    with: A.fetchId
                )
                await MainActor.run { if let data { self.dataId = data } }
                return data != nil
            }
            queue.addTask(priority: .background) {
                let data: [(DataId, String)]? = env.currencyRepository?.loadName()
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

    func loadGroup(env: EnvironmentManager, groupBy: AccountGroupBy) {
        log.trace("DEBUG: AccountViewModel.loadGroup(\(self.groupBy.rawValue)): main=\(Thread.isMainThread)")
        guard dataState == .ready && groupState != .loading else { return }
        groupState = .loading
        self.groupBy = groupBy
        groupByCurrency = []
        groupDataId = []
        groupIsVisible.removeAll(keepingCapacity: true)
        groupIsExpanded.removeAll(keepingCapacity: true)
        switch groupBy {
        case .void:
            addGroup(dataId, true, true)
        case .byType:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.type }
            for g in Self.groupByType {
                addGroup(dict[g] ?? [], dict[g] != nil, true)
            }
        case .byCurrency:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.currencyId }
            groupByCurrency = env.currencyCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in groupByCurrency {
                addGroup(dict[g] ?? [], dict[g] != nil, true)
            }
        case .byStatus:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.status }
            for g in Self.groupByStatus {
                addGroup(dict[g] ?? [], true, g == .open)
            }
        case .byFavorite:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.favoriteAcct }
            for g in Self.groupByFavorite {
                addGroup(dict[g] ?? [], true, g == .boolTrue)
            }
        }
        groupState = .ready
    }

    func groupIsVisible(_ g: Int) -> Bool {
        if search.isEmpty {
            return switch groupBy {
            case .byType, .byCurrency: !groupDataId[g].isEmpty
            default: true
            }
        }
        return groupDataId[g].first(where: { dataIsVisible($0) }) != nil
    }

    /*
    func loadCurrencyName() {
        currencyName = []
        guard let repository = env.currencyRepository else { return }
        DispatchQueue.global(qos: .background).async {
            let id_name = repository.loadName()
            DispatchQueue.main.async {
                self.currencyName = id_name
            }
        }
    }

    func loadDataById() {
        dataById = [:]
        guard let repository = env.accountRepository else { return }
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
        guard let repository = env.accountRepository else { return }
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
