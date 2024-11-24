//
//  BudgetReload.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadBudget(_ pref: Preference, _ oldData: BudgetData?, _ newData: BudgetData?) async {
        log.trace("DEBUG: ViewModel.reloadBudget(main=\(Thread.isMainThread))")

        reloadBudgetPeriodUsed(pref, oldData?.periodId, newData?.periodId)
        reloadCategoryUsed(pref, oldData?.categoryId, newData?.categoryId)

        // save isExpanded
        let groupIsExpanded: [Bool]? = budgetGroup.readyValue?.map { $0.isExpanded }
        let periodIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: budgetGroup.groupPeriod.enumerated().map { ($0.1, $0.0) }
        )
        let categoryIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: budgetGroup.groupCategory.enumerated().map { ($0.1, $0.0) }
        )

        unloadBudgetGroup()
        budgetList.unloadNone()

        if (oldData != nil) != (newData != nil) {
            budgetList.count.unload()
        }

        if budgetList.data.state.unloading() {
            if let newData {
                budgetList.data.value[newData.id] = newData
            } else if let oldData {
                budgetList.data.value[oldData.id] = nil
            }
            budgetList.data.state.loaded()
        }

        budgetList.order.unload()

        await loadBudgetList(pref)
        loadBudgetGroup(choice: budgetGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch budgetGroup.choice {
        case .period:
            for (g, periodId) in budgetGroup.groupPeriod.enumerated() {
                guard let i = periodIndex[periodId] else { continue }
                budgetGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        case .category:
            for (g, categoryId) in budgetGroup.groupCategory.enumerated() {
                guard let i = categoryIndex[categoryId] else { continue }
                budgetGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if budgetGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    budgetGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadBudget(main=\(Thread.isMainThread))")
    }
}
