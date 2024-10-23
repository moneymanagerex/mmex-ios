//
//  AccountViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

enum AccountGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case favorite   = "Favorite"
    case type       = "Type"
    case currency   = "Currency"
    case status     = "Status"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AccountGroup: RepositoryLoadGroupProtocol {
    typealias GroupChoice    = AccountGroupChoice
    typealias MainRepository = AccountRepository

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[RepositoryGroupData]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []

    static let groupUsed: [Bool] = [
        true, false
    ]

    static let groupFavorite: [AccountFavorite] = [
        .boolTrue, .boolFalse
    ]

    static let groupType: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment
    ]

    var groupCurrency: [DataId] = []

    static let groupStatus: [AccountStatus] = [
        .open, .closed
    ]

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

struct AccountSearch: RepositorySearchProtocol {
    var area: [RepositorySearchArea<AccountData>] = [
        ("Name",  true,  [ {$0.name} ]),
        ("Notes", false, [ {$0.notes} ]),
        ("Other", false, [ {$0.num}, {$0.heldAt}, {$0.website}, {$0.contactInfo}, {$0.accessInfo} ]),
    ]
    var key: String = ""
}

extension RepositoryViewModel {
    func loadAccountList() async {
        log.trace("DEBUG: RepositoryViewModel.loadAccountList(main=\(Thread.isMainThread))")
        guard case .idle = accountList.state else { return }
        accountList.state = .loading
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.accountData)
            load(queue: &queue, keyPath: \Self.accountOrder)
            load(queue: &queue, keyPath: \Self.accountUsed)
            load(queue: &queue, keyPath: \Self.accountAtt)
            // needed in EditForm
            load(queue: &queue, keyPath: \Self.currencyName)
            load(queue: &queue, keyPath: \Self.currencyOrder)
            return await allOk(queue: queue)
        }
        accountList.state = queueOk ? .ready(()) : .error("Cannot load.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadAccountList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadAccountList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadAccountList() {
        log.trace("DEBUG: RepositoryViewModel.unloadAccountList(main=\(Thread.isMainThread))")
        if case .loading = accountList.state { return }
        accountList.state = .loading
        accountData.unload()
        accountOrder.unload()
        accountUsed.unload()
        accountAtt.unload()
        accountList.state = .idle
    }
}

extension RepositoryViewModel {
    func loadAccountGroup(env: EnvironmentManager, choice: AccountGroupChoice) {
        log.trace("DEBUG: RepositoryViewModel.loadAccountGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        guard case .idle = accountGroup.state else { return }
        guard
            case .ready(_) = accountList.state,
            case let .ready(dataDict)  = accountData.state,
            case let .ready(dataOrder) = accountOrder.state,
            case let .ready(dataUsed)  = accountUsed.state,
            case let .ready(dataAtt)   = accountAtt.state
        else { return }

        accountGroup.state = .loading
        accountGroup.choice = choice
        accountGroup.groupCurrency = []

        var groupTuple: RepositoryGroup.AsTuple = ([], [], [])
        switch choice {
        case .all:
            RepositoryGroup.append(into: &groupTuple, "All", dataOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: dataOrder) { dataUsed.contains($0) }
            for g in AccountGroup.groupUsed {
                let name = g ? "Used" : "Other"
                RepositoryGroup.append(into: &groupTuple, name, dict[g] ?? [], true, g)
            }
        case .favorite:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.favoriteAcct }
            for g in AccountGroup.groupFavorite {
                let name = g == .boolTrue ? "Favorite" : "Other"
                RepositoryGroup.append(into: &groupTuple, name, dict[g] ?? [], true, g == .boolTrue)
            }
        case .type:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.type }
            for g in AccountGroup.groupType {
                RepositoryGroup.append(into: &groupTuple, g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.currencyId }
            accountGroup.groupCurrency = env.currencyCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in accountGroup.groupCurrency {
                let name = env.currencyCache[g]?.name
                RepositoryGroup.append(into: &groupTuple, name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .status:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.status }
            for g in AccountGroup.groupStatus {
                RepositoryGroup.append(into: &groupTuple, g.rawValue, dict[g] ?? [], true, g == .open)
            }
        case .attachment:
            let dict = Dictionary(grouping: dataOrder) { dataAtt[$0]?.count ?? 0 > 0 }
            for g in AccountGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                RepositoryGroup.append(into: &groupTuple, name, dict[g] ?? [], true, g)
            }
        }

        accountGroup.isVisible  = groupTuple.isVisible
        accountGroup.isExpanded = groupTuple.isExpanded
        accountGroup.state = .ready(groupTuple.groupData)
    }

    func unloadAccountGroup() {
        log.trace("DEBUG: RepositoryViewModel.unloadAccountGroup(main=\(Thread.isMainThread))")
        if case .loading = accountGroup.state { return }
        accountGroup.state = .loading
        accountGroup.isVisible  = []
        accountGroup.isExpanded = []
        accountGroup.state = .idle
    }
}

extension RepositoryViewModel {
    func accountGroupIsVisible(_ g: Int, search: AccountSearch) -> Bool? {
        guard
            case let .ready(dataDict) = accountData.state,
            case let .ready(groupData) = accountGroup.state
        else { return nil }
        if search.isEmpty {
            return switch accountGroup.choice {
            case .type, .currency: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(dataDict[$0]!) }) != nil
    }

    func searchAccountGroup(search: AccountSearch, expand: Bool = false) {
        //log.trace("DEBUG: RepositoryViewModel.searchAccountGroup()")
        guard case let .ready(groupData) = accountGroup.state else { return }
        for g in 0 ..< groupData.count {
            guard let isVisible = accountGroupIsVisible(g, search: search) else { return }
            //log.debug("DEBUG: RepositoryViewModel.searchAccountGroup(): \(g) = \(isVisible)")
            accountGroup.isVisible[g] = isVisible
            if (expand || !search.isEmpty) && isVisible {
                accountGroup.isExpanded[g] = true
            }
        }
    }
}

extension RepositoryViewModel {
    func updateAccount(_ data: inout AccountData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        if case let .ready(currency) = currencyName.state {
            if data.currencyId <= 0 {
                return "No currency is selected"
            } else if currency[data.currencyId] == nil {
                return "* Unknown currency #\(data.currencyId)"
            }
        } else {
            return "* currencyName is not loaded"
        }

        typealias A = AccountRepository
        guard let a = A(env) else {
            return "* Database is not available"
        }

        guard let dataName = a.selectId(from: A.table.filter(
            A.table[A.col_id] == Int64(data.id) || A.table[A.col_name] == data.name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id <= 0 ? 0 : 1) else {
            return "Account \(data.name) already exists"
        }

        if data.id <= 0 {
            guard a.insert(&data) else {
                return "* Cannot create new account"
            }
        } else {
            guard a.update(data) else {
                return "* Cannot update account #\(data.id)"
            }
        }

        return nil
    }
}

extension RepositoryViewModel {
    func deleteAccount(_ data: AccountData) -> String? {
        if case let .ready(used) = accountUsed.state {
            if used.contains(data.id) {
                return "* Account #\(data.id) is used"
            }
        } else {
            return "* accountUsed is not loaded"
        }

        guard
            let a = AccountRepository(env),
            let ax = AttachmentRepository(env)
        else {
            return "* Database is not available"
        }

        if case let .ready(att) = accountAtt.state {
            if att[data.id] != nil {
                guard ax.delete(refType: .account, refId: data.id) else {
                    return "* Cannot delete attachments for account #\(data.id)"
                }
            }
        } else {
            return "* accountAtt is not loaded"
        }

        guard a.delete(data) else {
            return "* Cannot delete account #\(data.id)"
        }

        return nil
    }
}

extension RepositoryViewModel {
    func reloadAccount(_ oldData: AccountData?, _ newData: AccountData?) async {
        if let newData {
            if env.currencyCache[newData.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: newData.id, data: newData)
        } else if let oldData {
            env.accountCache[oldData.id] = nil
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = switch accountGroup.state {
        case .ready(_): accountGroup.isExpanded
        default: nil
        }
        var currencyIsExpanded: [DataId: Bool] = [:]
        if let groupIsExpanded, case .currency = accountGroup.choice {
            for (i, currencyId) in accountGroup.groupCurrency.enumerated() {
                currencyIsExpanded[currencyId] = groupIsExpanded[i]
            }
        }

        // TODO: improve performance
        unloadAccountGroup()
        unloadAccountList()
        await loadAccountList()
        loadAccountGroup(env: env, choice: accountGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch accountGroup.choice {
        case .currency:
            for (i, currencyId) in accountGroup.groupCurrency.enumerated() {
                if let isExpanded = currencyIsExpanded[currencyId] {
                    accountGroup.isExpanded[i] = isExpanded
                }
            }
        default:
            if accountGroup.isExpanded.count == groupIsExpanded.count {
                accountGroup.isExpanded = groupIsExpanded
            }
        } }
    }
}
