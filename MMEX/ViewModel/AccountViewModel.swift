//
//  AccountViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case favorite   = "Favorite"
    case type       = "Type"
    case currency   = "Currency"
    case status     = "Status"
    case attachment = "Att." // full name does not fit in iPhoneSE display
    static let defaultValue = Self.all

    static let isSingleton: Set<Self> = [.all]
    var fullName: String {
        switch self { case .attachment: "Attachment"; default: rawValue }
    }
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
        accountData.unload()
        accountOrder.unload()
        accountUsed.unload()
        accountAtt.unload()
        accountList.state = .idle
    }
}

extension RepositoryViewModel {
    func loadAccountGroup(env: EnvironmentManager, choice: AccountGroupChoice) -> Bool? {
        log.trace("DEBUG: RepositoryViewModel.loadAccountGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        if case .loading = accountGroup.state { return nil }
        guard
            case .ready(_) = accountList.state,
            case let .ready(dataDict)  = accountData.state,
            case let .ready(dataOrder) = accountOrder.state,
            case let .ready(dataUsed)  = accountUsed.state,
            case let .ready(dataAtt)   = accountAtt.state
        else { return nil }

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
    func validateAccount(_ data: AccountData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        // TODO: data.name is unique

        if case let .ready(currency) = currencyName.state {
            if data.currencyId <= 0 {
                return "No currency is selected"
            } else if currency[data.currencyId] == nil {
                return "* Unknown currency #\(data.currencyId)"
            }
        } else {
            return "* currencyName is not loaded"
        }

        return nil
    }
}

extension RepositoryViewModel {
    func createAccount(_ data: inout AccountData) -> String? {
        if let validateError = validateAccount(data) {
            return validateError
        }

        guard let repository = AccountRepository(env) else {
            return "* Database is not available"
        }
        guard repository.insert(&data) else {
            return "* Cannot create new account"
        }

        return nil
    }
}

extension RepositoryViewModel {
    func updateAccount(_ data: AccountData) -> String? {
        if let validateError = validateAccount(data) {
            return validateError
        }

        guard let repository = AccountRepository(env) else {
            return "* Database is not available"
        }
        guard repository.update(data) else {
            return "* Cannot update account #\(data.id)"
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

        guard let repository = AccountRepository(env) else {
            return "* Database is not available"
        }
        guard repository.delete(data) else {
            return "* Cannot delete account \(data.id)"
        }

        return nil
    }
}

extension RepositoryViewModel {
    func reload(_ oldData: AccountData?, _ newData: AccountData?) async {
        if let newData {
            if env.currencyCache[newData.currencyId] == nil {
                // TODO: loadCurrency() -> addCurrency()
                env.loadCurrency()
            }
            env.accountCache.update(id: newData.id, data: newData)
        } else if let _ = oldData {
            // TODO: loadAccount() -> removeAccount()
            env.loadAccount()
        }

        // TODO: update vm
        _ = unloadAccountGroup()
        unloadAccountList()
        await loadAccountList()
        _ = loadAccountGroup(env: env, choice: accountGroup.choice)
    }
}
