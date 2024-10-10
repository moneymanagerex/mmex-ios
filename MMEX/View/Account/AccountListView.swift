//
//  AccountListView.swift
//  MMEX
//
//  2024-09-05: Created by Lisheng Guan
//  2024-10-07: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountPartition: String, RepositoryPartitionProtocol {
    case void       = "Group:"
    case byType     = "by Type"
    case byCurrency = "by Currency"
    case byStatus   = "by Status"
    case byFavorite = "by Favorite"
    static let defaultValue = Self.void

    func nameView<NameView: View>(
        ofSection s: Int,
        env: EnvironmentManager,
        sectionCurrencyId: [Int64]
    ) -> NameView {
        Group {
            switch self {
            case .void:
                Text("All Accounts")
            case .byType:
                HStack {
                    Image(systemName: Self.groupByType[s].symbolName)
                        .frame(width: 5, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    Text(Self.sectionType[s].rawValue)
                        //.font(.subheadline)
                        //.padding(.leading)
                }
            case .byCurrency:
                Text(env.currencyCache[sectionCurrencyId[s]]?.name ?? "ERROR: unknown currency")
            case .byStatus:
                Text(Self.sectionStatus[s].rawValue)
            case .byFavorite:
                Text(Self.sectionFavorite[s] ? "Favorite" : "Other")
            }
        } as! NameView
    }
}

class AccountViewModel: RepositoryViewModelProtocol {
    typealias RepositoryData = AccountData
    typealias RepositoryPartition = AccountPartition

    var env: EnvironmentManager
    var allCurrencyName: [(Int64, String)]? // sorted by name
    @Published private(set) var dataById: [Int64 : AccountData]?
    @Published var group: [RepositoryGroup]?
    var partition = AccountPartition.defaultValue
    var search = ""

    static let newData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    static let groupByType: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment
    ]

    var groupByCurrency: [Int64]?

    static let groupByStatus: [AccountStatus] = [
        .open, .closed
    ]

    static let groupByFavorite: [AccountFavorite] = [
        .boolTrue, .boolFalse
    ]

    required init(env: EnvironmentManager) {
        self.env = env
    }

    var dataIsReady: Bool { allCurrencyName != nil && dataById != nil }

    func loadData() {
        loadCurrencyName()
        loadDataById()
    }

    func loadGroup() {
        group = nil
        groupByCurrency = nil
        switch partition {
        case .void:
            loadAll()
        case .byType:
            loadGroupByType()
        case .byCurrency:
            loadGroupByCurrency()
        case .byStatus:
            loadGroupByStatus()
        case .byFavorite:
            loadGroupByFavorite()
        }
    }

    func loadCurrencyName() {
        allCurrencyName = nil
        guard let repository = env.currencyRepository else { return }
        DispatchQueue.global(qos: .background).async {
            let id_name = repository.loadName()
            DispatchQueue.main.async {
                self.allCurrencyName = id_name
            }
        }
    }

    func loadDataById() {
        dataById = nil
        guard let repository = env.accountRepository else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dataById: [Int64: RepositoryData] = repository.dict(
                from: A.table.order(A.col_name)
            )
            DispatchQueue.main.async {
                self.dataById = dataById
            }
        }
    }

    func loadAll() {
        guard let repository = env.accountRepository else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let id: [Int64] = repository.select(
                from: A.table.order(A.col_name),
                with: A.fetchId
            )
            DispatchQueue.main.async {
                self.group = [RepositoryGroup(
                    dataId: id, isVisible: true, isExpanded: true
                ) ]
            }
        }
    }

    func loadGroupByType() {
        guard let repository = env.accountRepository else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dictByType: [AccountType: [Int64]] = repository.loadByType(
                from: A.table.order(A.col_name),
                with: A.fetchId
            )
            DispatchQueue.main.async {
                self.group = []
                for type in Self.groupByType {
                    guard let id = dictByType[type] else { return }
                    self.group!.append(RepositoryGroup(
                        dataId: id, isVisible: true, isExpanded: true
                    ) )
                }
            }
        }
    }

    func loadGroupByCurrency() {
        guard let repository = env.accountRepository else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dictByCurrency: [Int64: [Int64]] = repository.loadByCurrecncyId(
                from: A.table.order(A.col_name),
                with: A.fetchId
            )
            DispatchQueue.main.async {
                self.group = []
                self.groupByCurrency = []
                let currencyIds = self.env.currencyCache.map { ($0.key, $0.value.name) }
                    .sorted { $0.1 < $1.1 }.map { $0.0 }
                for currencyId in currencyIds {
                    guard let id = dictByCurrency[currencyId] else { return }
                    self.groupByCurrency!.append(currencyId)
                    self.group!.append(RepositoryGroup(
                        dataId: id, isVisible: true, isExpanded: true
                    ) )
                }
            }
        }
    }

    func loadGroupByStatus() {
        guard let repository = env.accountRepository else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dictByStatus: [AccountStatus: [Int64]] = repository.loadByStatus(
                from: A.table.order(A.col_name),
                with: A.fetchId
            )
            DispatchQueue.main.async {
                self.group = []
                for status in Self.groupByStatus {
                    guard let id = dictByStatus[status] else { return }
                    self.group!.append(RepositoryGroup(
                        dataId: id, isVisible: true, isExpanded: status == .open
                    ) )
                }
            }
        }
    }

    func loadGroupByFavorite() {
        guard let repository = env.accountRepository else { return }
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dictByFavorite: [AccountFavorite: [Int64]] = repository.loadByFavorite(
                from: A.table.order(A.col_name),
                with: A.fetchId
            )
            DispatchQueue.main.async {
                self.group = []
                for fav in Self.groupByFavorite {
                    guard let id = dictByFavorite[fav] else { return }
                    self.group!.append(RepositoryGroup(
                        dataId: id, isVisible: true, isExpanded: fav == .boolTrue
                    ) )
                }
            }
        }
    }

    func isVisible(data: AccountData) -> Bool {
        search.isEmpty || data.name.localizedCaseInsensitiveContains(search)
    }
}

typealias AccountListView<GroupNameView: View, ItemNameView: View> = RepositoryListView<
    AccountData, AccountPartition, AccountViewModel,
    GroupNameView, ItemNameView
>

#Preview {
    AccountListView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}
