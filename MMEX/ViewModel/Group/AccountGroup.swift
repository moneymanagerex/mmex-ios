//
//  AccountGroup.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AccountGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case favorite   = "Favorite"
    case status     = "Status"
    case type       = "Type"
    case currency   = "Currency"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AccountGroup: GroupProtocol {
    typealias MainRepository = AccountRepository
    typealias GroupChoice    = AccountGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.account"
    }

    static let groupUsed: [Bool] = [
        true, false
    ]

    static let groupFavorite: [AccountFavorite] = [
        .boolTrue, .boolFalse
    ]

    static let groupStatus: [AccountStatus] = [
        .open, .closed
    ]

    static let groupType: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment
    ]

    var groupCurrency: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

extension ViewModel {
    func loadAccountGroup(choice: AccountGroupChoice) {
        guard
            let listData      = accountList.data.readyValue,
            let listUsed      = accountList.used.readyValue,
            let listOrder     = accountList.order.readyValue,
            let listAtt       = accountList.attachment.readyValue,
            let currencyName  = currencyList.name.readyValue,
            let currencyOrder = currencyList.order.readyValue
        else { return }

        guard accountGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAccountGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        accountGroup.choice = choice
        accountGroup.search = false
        accountGroup.groupCurrency = []

        switch choice {
        case .all:
            accountGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in AccountGroup.groupUsed {
                let name = g ? "Used" : "Other"
                accountGroup.append(name, dict[g] ?? [], true, g)
            }
        case .favorite:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.favoriteAcct }
            for g in AccountGroup.groupFavorite {
                let name = g == .boolTrue ? "Favorite" : "Other"
                accountGroup.append(name, dict[g] ?? [], true, g == .boolTrue)
            }
        case .status:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.status }
            for g in AccountGroup.groupStatus {
                accountGroup.append(g.rawValue, dict[g] ?? [], true, true)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in AccountGroup.groupType {
                accountGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.currencyId }
            accountGroup.groupCurrency = currencyOrder.compactMap {
                dict[$0] != nil ? $0 : nil
            }
            for g in accountGroup.groupCurrency {
                let name = currencyName[g]
                accountGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in AccountGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                accountGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        accountGroup.state.loaded()
        log.info("INFO: ViewModel.loadAccountGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
