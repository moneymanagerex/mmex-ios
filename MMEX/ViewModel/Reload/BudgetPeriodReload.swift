//
//  BudgetPeriodReload.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadBudgetPeriod(_ pref: Preference, _ oldData: BudgetPeriodData?, _ newData: BudgetPeriodData?) async {
        log.trace("DEBUG: ViewModel.reloadBudgetPeriod(main=\(Thread.isMainThread))")

        if oldData?.name != newData?.name {
            if budgetGroup.choice == .period { budgetGroup.unload() }
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = budgetPeriodGroup.readyValue?.map { $0.isExpanded }

        budgetPeriodGroup.unload()
        budgetPeriodList.unloadNone()

        if (oldData != nil) != (newData != nil) {
            budgetPeriodList.count.unload()
        }

        if budgetPeriodList.data.state.unloading() {
            if let newData {
                budgetPeriodList.data.value[newData.id] = newData
            } else if let oldData {
                budgetPeriodList.data.value[oldData.id] = nil
            }
            budgetPeriodList.data.state.loaded()
        }

        budgetPeriodList.order.unload()

        await loadBudgetPeriodList(pref)
        loadBudgetPeriodGroup(choice: budgetPeriodGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch budgetPeriodGroup.choice {
        default:
            if budgetPeriodGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    budgetPeriodGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadBudgetPeriod(main=\(Thread.isMainThread))")
    }

    func reloadBudgetPeriodUsed(_ pref: Preference, _ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadBudgetPeriodUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        if let oldId, newId != oldId {
            if budgetPeriodGroup.choice == .used {
                budgetPeriodGroup.unload()
            }
            budgetPeriodList.used.unload()
        } else if
            let budgetPeriodUsed = budgetPeriodList.used.readyValue,
            let newId, !budgetPeriodUsed.contains(newId)
        {
            if budgetPeriodGroup.choice == .used {
                budgetPeriodGroup.unload()
            }
            if budgetPeriodList.used.state.unloading() {
                budgetPeriodList.used.value.insert(newId)
                budgetPeriodList.used.state.loaded()
            }
        }
    }
}
