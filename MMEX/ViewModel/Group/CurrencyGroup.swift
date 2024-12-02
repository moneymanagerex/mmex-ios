//
//  CurrencyGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum CurrencyGroupChoice: String, GroupChoiceProtocol {
    case all  = "All"
    case used = "Used"
    case type = "Type"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct CurrencyGroup: GroupProtocol {
    typealias MainRepository = CurrencyRepository
    typealias GroupChoice    = CurrencyGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
        self.$choice = "manage.group.currency"
    }

    static let groupUsed : [Bool] = [true, false]
    static let groupType : [CurrencyType] = [.fiat, .crypto]
}

extension ViewModel {
    func loadCurrencyGroup(choice: CurrencyGroupChoice) {
        guard
            let listData  = currencyList.data.readyValue,
            let listUsed  = currencyList.used.readyValue,
            let listOrder = currencyList.order.readyValue
        else { return }

        guard currencyGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCurrencyGroup(\(choice.rawValue), main=\(Thread.isMainThread))")

        currencyGroup.choice = choice
        currencyGroup.search = false

        switch choice {
        case .all:
            currencyGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in CurrencyGroup.groupUsed {
                let name = g ? "Used" : "Other"
                currencyGroup.append(name, dict[g] ?? [], true, g)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in CurrencyGroup.groupType {
                currencyGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        }

        currencyGroup.state.loaded()
        log.info("INFO: ViewModel.loadCurrencyGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
