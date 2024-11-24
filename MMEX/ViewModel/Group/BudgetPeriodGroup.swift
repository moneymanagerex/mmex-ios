//
//  BudgetPeriodGroup.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum BudgetPeriodGroupChoice: String, GroupChoiceProtocol {
    case all  = "All"
    case used = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct BudgetPeriodGroup: GroupProtocol {
    typealias MainRepository = BudgetPeriodRepository
    typealias GroupChoice    = BudgetPeriodGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.budgetPeriod"
    }

    static let groupUsed: [Bool] = [
        true, false
    ]
}

extension ViewModel {
    func loadBudgetPeriodGroup(choice: BudgetPeriodGroupChoice) {
        guard
            let listUsed    = budgetPeriodList.used.readyValue,
            let listOrder   = budgetPeriodList.order.readyValue
        else { return }

        guard budgetPeriodGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadBudgetPeriodGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        budgetPeriodGroup.choice = choice
        budgetPeriodGroup.search = false

        switch choice {
        case .all:
            budgetPeriodGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in BudgetPeriodGroup.groupUsed {
                let name = g ? "Used" : "Other"
                budgetPeriodGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        budgetPeriodGroup.state.loaded()
        log.info("INFO: ViewModel.loadBudgetPeriodGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
