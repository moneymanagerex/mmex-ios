//
//  BudgetGroup.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum BudgetGroupChoice: String, GroupChoiceProtocol {
    case period   = "Period"
    case category = "Category"
    case active   = "Active"
    static let defaultValue = Self.period
    static let isSingleton: Set<Self> = []
}

struct BudgetGroup: GroupProtocol {
    typealias MainRepository = BudgetRepository
    typealias GroupChoice    = BudgetGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @Preference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
        self.$choice = "manage.group.budget"
    }

    var groupPeriod: [DataId] = []

    var groupCategory: [DataId] = []

    static let groupActive: [Bool] = [
        true, false
    ]
}

extension ViewModel {
    func loadBudgetGroup(choice: BudgetGroupChoice) {
        guard
            let listData      = budgetList.data.readyValue,
            let evalOrder     = budgetList.evalOrder.readyValue,
            let periodData    = budgetPeriodList.data.readyValue,
            let periodOrder   = budgetPeriodList.order.readyValue,
            let categoryPath  = categoryList.evalPath.readyValue,
            let categoryOrder = categoryList.evalTree.readyValue?.order
        else { return }

        guard budgetGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadBudgetGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        budgetGroup.choice = choice
        stockGroup.search = false
        budgetGroup.groupPeriod = []
        budgetGroup.groupCategory = []

        switch choice {
        case .period:
            let dict = Dictionary(grouping: evalOrder) { listData[$0]!.periodId }
            budgetGroup.groupPeriod = [.void] + periodOrder.compactMap {
                dict[$0] != nil ? $0 : nil
            }
            for g in budgetGroup.groupPeriod {
                let name = periodData[g]?.name ?? "(unknown)"
                budgetGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .category:
            let dict = Dictionary(grouping: evalOrder) { listData[$0]!.categoryId }
            budgetGroup.groupCategory = [.void] + categoryOrder.compactMap {
                dict[$0.dataId] != nil ? $0.dataId : nil
            }
            for g in budgetGroup.groupCategory {
                let name = g.isVoid ? "(none)" : categoryPath[g] ?? "(unknown)"
                budgetGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .active:
            let dict = Dictionary(grouping: evalOrder) { listData[$0]!.active }
            for g in BudgetGroup.groupActive {
                let name = g ? "Active" : "Other"
                budgetGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        budgetGroup.state.loaded()
        log.info("INFO: ViewModel.loadBudgetGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }

    func unloadBudgetGroup() {
        budgetGroup.unload()
    }
}
