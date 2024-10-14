//
//  AccountListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountGroupBy: String, RepositoryGroupByProtocol {
    case void       = "Group:"
    case byType     = "by Type"
    case byCurrency = "by Currency"
    case byStatus   = "by Status"
    case byFavorite = "by Favorite"
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

    private(set) var env: EnvironmentManager

    @Published
    var dataState: RepositoryLoadState = .idle
    var dataById: [DataId : RepositoryData] = [:]
    private var dataId: [DataId] = [] // sorted by name
    private(set) var currencyName: [(DataId, String)] = [] // sorted by name

    var groupBy = AccountGroupBy.defaultValue
    @Published
    var groupState: RepositoryLoadState = .idle
    @Published
    var groupDataId: [[DataId]] = []

    var search = AccountSearch()
    @Published
    var groupIsVisible  : [Bool] = []
    @Published
    var groupIsExpanded : [Bool] = []

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

    required init(env: EnvironmentManager) {
        self.env = env
    }

    func unloadData() {
        log.trace("DEBUG: AccountViewModel.unloadData(): main=\(Thread.isMainThread)")
        if groupState != .idle { unloadGroup() }
        dataState = .idle
        dataById.removeAll()
        dataId = []
        currencyName = []
    }

    enum LoadTaskData {
        case dataById([DataId: RepositoryData]?)
        case dataId([DataId]?)
        case currencyName([(DataId, String)]?)
    }
    typealias LoadData = (
        dataById: [DataId: RepositoryData],
        dataId: [DataId],
        currencyName: [(DataId, String)]
    )

    func loadData() async {
        log.trace("DEBUG: AccountViewModel.loadData(): main=\(Thread.isMainThread)")
        if dataState != .idle { unloadData() }
        dataState = .loading
        log.debug("DEBUG: AccountViewModel.loadData(): dataState=\(self.dataState.rawValue)")
        log.debug("DEBUG: AccountViewModel.loadData(): groupState=\(self.groupState.rawValue)")
        let data: LoadData? = await withTaskGroup(of: LoadTaskData.self) { queue -> LoadData? in
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                return await .dataById(self.env.accountRepository?.selectById(
                    from: A.table.order(A.col_name)
                ) )
            }
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                return await .dataId(self.env.accountRepository?.select(
                    from: A.table.order(A.col_name),
                    with: A.fetchId
                ) )
            }
            queue.addTask(priority: .background) {
                return await .currencyName(self.env.currencyRepository?.loadName())
            }

            var error = false
            var data: LoadData = (dataById: [:], dataId: [], currencyName: [])
            for await taskData in queue {
                switch taskData {
                case .dataById(let result):
                    if let result { data.dataById = result }
                    else { error = true }
                case .dataId(let result):
                    if let result { data.dataId = result }
                    else { error = true }
                case .currencyName(let result):
                    if let result { data.currencyName = result }
                    else { error = true }
                }
            }
            return error ? nil : data
        }

        if let data {
            dataById     = data.dataById
            dataId       = data.dataId
            currencyName = data.currencyName
            dataState = .ready
            log.info("INFO: AccountViewModel.loadData(): main=\(Thread.isMainThread), \(self.dataById.count), \(self.dataId.count), \(self.currencyName.count)")
        } else {
            dataState = .error
            log.error("ERROR: AccountViewModel.loadData(): main=\(Thread.isMainThread)")
        }
    }

    func addGroup(_ dataId: [DataId], _ isVisible: Bool, _ isExpanded: Bool) {
        groupDataId.append(dataId)
        groupIsVisible.append(isVisible)
        groupIsExpanded.append(isExpanded)
    }

    func loadGroup(_ groupBy: AccountGroupBy) {
        log.trace("DEBUG: AccountViewModel.loadGroup(\(groupBy.rawValue)): main=\(Thread.isMainThread)")
        guard dataState == .ready else { return }
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
            groupByCurrency = self.env.currencyCache.compactMap {
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
        if search.key.isEmpty {
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
