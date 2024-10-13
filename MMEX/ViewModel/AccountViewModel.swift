//
//  AccountListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountPartition: String, RepositoryPartitionProtocol {
    case void       = "Group:"
    case byType     = "by Type"
    case byCurrency = "by Currency"
    case byStatus   = "by Status"
    case byFavorite = "by Favorite"
    static let defaultValue = Self.void
}

class AccountViewModel: RepositoryViewModelProtocol {
    typealias RepositoryData      = AccountData
    typealias RepositoryPartition = AccountPartition

    var env: EnvironmentManager
    private(set) var currencyName: [(DataId, String)] = [] // sorted by name
    private(set) var dataById: [DataId : RepositoryData] = [:]
    private var dataId: [DataId] = [] // sorted by name
    @Published var dataIsReady = false
    @Published var group: [RepositoryGroup] = []
    @Published var groupIsReady = false
    var partition = AccountPartition.defaultValue
    var search = ""

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

    enum LoadData {
        case currencyName([(DataId, String)]?)
        case dataById([DataId: RepositoryData]?)
        case dataId([DataId]?)
    }

    func loadData() async -> Bool {
        log.trace("AccountViewModel.loadData()")
        var dataIsReady = true
        await withTaskGroup(of: LoadData.self) { queue -> () in
            queue.addTask(priority: .background) {
                return .currencyName(self.env.currencyRepository?.loadName())
            }
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                return .dataById(self.env.accountRepository?.selectById(
                    from: A.table.order(A.col_name)
                ) )
            }
            queue.addTask(priority: .background) {
                typealias A = AccountRepository
                return .dataId(self.env.accountRepository?.select(
                    from: A.table.order(A.col_name),
                    with: A.fetchId
                ) )
            }

            for await result in queue {
                switch result {
                case .currencyName(let result):
                    if let result { self.currencyName = result }
                    else { dataIsReady = false }
                case .dataById(let result):
                    if let result { self.dataById = result }
                    else { dataIsReady = false }
                case .dataId(let result):
                    if let result { self.dataId = result }
                    else { dataIsReady = false }
                }
            }
        }
        return dataIsReady
    }

    func newPartition(_ partition: RepositoryPartition) -> Bool {
        log.trace("AccountViewModel.newPartition()")
        guard dataIsReady else { return false }
        group = []
        groupByCurrency = []
        self.partition = partition
        switch partition {
        case .void:
            group = [ RepositoryGroup(
                dataId: dataId, isVisible: true, isExpanded: true
            ) ]
        case .byType:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.type }
            group = Self.groupByType.map { g in RepositoryGroup(
                dataId: dict[g] ?? [], isVisible: dict[g] != nil, isExpanded: true
            ) }
        case .byCurrency:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.currencyId }
            groupByCurrency = self.env.currencyCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            group = groupByCurrency.map { g in RepositoryGroup(
                dataId: dict[g] ?? [], isVisible: true, isExpanded: true
            ) }
        case .byStatus:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.status }
            group = Self.groupByStatus.map { g in RepositoryGroup(
                dataId: dict[g] ?? [], isVisible: true, isExpanded: g == .open
            ) }
        case .byFavorite:
            let dict = Dictionary(grouping: dataId) { dataById[$0]!.favoriteAcct }
            group = Self.groupByFavorite.map { g in RepositoryGroup(
                dataId: dict[g] ?? [], isVisible: true, isExpanded: g == .boolTrue
            ) }
        }
        return true
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

    func visible(data: AccountData) -> Bool {
        search.isEmpty || data.name.localizedCaseInsensitiveContains(search)
    }

    func visible(groupId g: Int) -> Bool {
        if search.isEmpty {
            return switch partition {
            case .byType: !group[g].dataId.isEmpty
            default: true
            }
        }
        return group[g].dataId.first(
            where: { visible(dataId: $0) }
        ) != nil
    }
}
