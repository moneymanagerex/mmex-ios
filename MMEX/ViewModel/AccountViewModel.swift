//
//  AccountViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountGroupChoice: String, RepositoryGroupChoiceProtocol {
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

struct AccountGroup: RepositoryLoadGroupProtocol {
    typealias GroupChoice    = AccountGroupChoice
    typealias RepositoryType = AccountRepository

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[[DataId]]> = .init()
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
}

extension RepositoryViewModel {
    func accountGroupIsVisible(_ g: Int, search: AccountSearch) -> Bool? {
        guard
            case let .ready(dataDict) = accountDataDict.state,
            case let .ready(dataId) = accountGroup.state
        else { return nil }
        if search.isEmpty {
            return switch accountGroup.choice {
            case .type, .currency: !dataId[g].isEmpty
            default: true
            }
        }
        return dataId[g].first(where: { search.match(dataDict[$0]!) }) != nil
    }

    func searchAccountGroup(search: AccountSearch, expand: Bool = false) {
        //log.trace("DEBUG: RepositoryViewModel.searchAccountGroup()")
        guard case let .ready(dataId) = accountGroup.state else { return }
        for g in 0 ..< dataId.count {
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
    func loadAccountList() async {
        log.trace("DEBUG: RepositoryViewModel.loadAccountList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.accountDataDict)
            load(queue: &queue, keyPath: \Self.accountDataOrder)
            load(queue: &queue, keyPath: \Self.accountDataUsed)
            load(queue: &queue, keyPath: \Self.currencyDataName)
            load(queue: &queue, keyPath: \Self.currencyDataOrder)
            return await allOk(queue: queue)
        }
        accountList.state = queueOk ? .ready(()) : .error("Cannot load data.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadAccountList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadAccountList(main=\(Thread.isMainThread)): Cannot load data.")
            return
        }
    }

    func unloadAccountList() {
        log.trace("DEBUG: RepositoryViewModel.unloadAccountList(main=\(Thread.isMainThread))")
        accountDataDict.unload()
        accountDataOrder.unload()
        accountDataUsed.unload()
        accountList.state = .idle
    }
}

extension RepositoryViewModel {
    func loadAccountGroup(env: EnvironmentManager, choice: AccountGroupChoice) -> Bool? {
        log.trace("DEBUG: RepositoryViewModel.loadAccountGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        if case .loading = accountGroup.state { return nil }
        guard
            case .ready(_) = accountList.state,
            case let .ready(dataDict)  = accountDataDict.state,
            case let .ready(dataOrder) = accountDataOrder.state,
            case let .ready(dataUsed)  = accountDataUsed.state
        else { return nil }

        accountGroup.state = .loading
        accountGroup.choice = choice
        accountGroup.groupCurrency = []

        var group: RepositoryGroup.AsTuple = ([], [], [])
        switch choice {
        case .all:
            RepositoryGroup.append(into: &group, dataOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: dataOrder) { dataUsed.contains($0) }
            for g in AccountGroup.groupUsed {
                RepositoryGroup.append(into: &group, dict[g] ?? [], true, g)
            }
        case .favorite:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.favoriteAcct }
            for g in AccountGroup.groupFavorite {
                RepositoryGroup.append(into: &group, dict[g] ?? [], true, g == .boolTrue)
            }
        case .type:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.type }
            for g in AccountGroup.groupType {
                RepositoryGroup.append(into: &group, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.currencyId }
            accountGroup.groupCurrency = env.currencyCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in accountGroup.groupCurrency {
                RepositoryGroup.append(into: &group, dict[g] ?? [], dict[g] != nil, true)
            }
        case .status:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.status }
            for g in AccountGroup.groupStatus {
                RepositoryGroup.append(into: &group, dict[g] ?? [], true, g == .open)
            }
        }

        accountGroup.isVisible  = group.isVisible
        accountGroup.isExpanded = group.isExpanded
        accountGroup.state = .ready(group.dataId)
        return true
    }

    func unloadAccountGroup() -> Bool? {
        log.trace("DEBUG: RepositoryViewModel.unloadAccountGroup(main=\(Thread.isMainThread))")
        if case .loading = accountGroup.state { return nil }
        accountGroup.state = .idle
        accountGroup.isVisible  = []
        accountGroup.isExpanded = []
        return true
    }
}
