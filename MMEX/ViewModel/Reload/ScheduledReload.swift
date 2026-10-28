//
//  ScheduledReload.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/10/28.
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadScheduled(_ pref: Preference, _ oldData: ScheduledData?, _ newData: ScheduledData?) async {
        log.trace("DEBUG: ViewModel.reloadScheduled(main=\(Thread.isMainThread))")

        // 1. Update dependency "used" states
        // Account used status may change (Source Account or Target Account)
        reloadAccountUsed(pref, oldData?.accountId, newData?.accountId)
        reloadAccountUsed(pref, oldData?.toAccountId, newData?.toAccountId)
        
        // Payee used status may change (only when it's not a Transfer)
        if oldData?.transCode != .transfer || newData?.transCode != .transfer {
            reloadPayeeUsed(pref, oldData?.payeeId, newData?.payeeId)
        }
        
        // Category used status may change
        reloadCategoryUsed(pref, oldData?.categId, newData?.categId)

        // 2. Save current group expanded states
        let groupIsExpanded: [Bool]? = scheduledGroup.readyValue?.map { $0.isExpanded }
        
        // Save Account and Category group indices to restore expanded states later
        let accountIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: scheduledGroup.groupAccount.enumerated().map { ($0.1, $0.0) }
        )
        let categoryIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: scheduledGroup.groupCategory.enumerated().map { ($0.1, $0.0) }
        )

        // 3. Unload Group and List caches
        scheduledGroup.unload()
        scheduledList.unloadNone()

        // 4. Handle Count state
        // If an item is added or deleted, unload count to force a new database query
        if (oldData != nil) != (newData != nil) {
            scheduledList.count.unload()
        }

        // 5. Update Data cache (partial update)
        if scheduledList.data.state.unloading() {
            if let newData {
                scheduledList.data.value[newData.id] = newData
            } else if let oldData {
                scheduledList.data.value[oldData.id] = nil
            }
            scheduledList.data.state.loaded()
        }

        // 6. Unload Order and other associated data (e.g., attachments, splits)
        scheduledList.order.unload()
        
        if let _ = newData {
            scheduledList.attachment.unload()
            scheduledList.split.unload()
        } else if let oldData {
            if scheduledList.attachment.state.unloading() {
                scheduledList.attachment.value[oldData.id] = nil
                scheduledList.attachment.state.loaded()
            }
            if scheduledList.split.state.unloading() {
                scheduledList.split.value[oldData.id] = nil
                scheduledList.split.state.loaded()
            }
        }

        // 7. Reload from the database
        await loadScheduledList(pref)
        loadScheduledGroup(choice: scheduledGroup.choice)

        // 8. Restore group expanded states
        if let groupIsExpanded { switch scheduledGroup.choice {
        case .account:
            for (g, accountId) in scheduledGroup.groupAccount.enumerated() {
                guard let i = accountIndex[accountId] else { continue }
                scheduledGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        case .category:
            for (g, categoryId) in scheduledGroup.groupCategory.enumerated() {
                guard let i = categoryIndex[categoryId] else { continue }
                scheduledGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if scheduledGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    scheduledGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadScheduled(main=\(Thread.isMainThread))")
    }

    // MARK: - Helper Methods
    
    func reloadScheduledUsed(_ pref: Preference, _ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadScheduledUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        
        // ScheduledList's used set is always empty, but we still handle group invalidation
        if let oldId, newId != oldId {
            scheduledGroup.unload()
            scheduledList.used.unload()
        } else if
            let scheduledUsed = scheduledList.used.readyValue,
            let newId, !scheduledUsed.contains(newId)
        {
            scheduledGroup.unload()
            if scheduledList.used.state.unloading() {
                scheduledList.used.value.insert(newId)
                scheduledList.used.state.loaded()
            }
        }
    }

    func reloadScheduledAtt(_ pref: Preference) {
        log.trace("DEBUG: ViewModel.reloadScheduledAtt(main=\(Thread.isMainThread))")
        if scheduledGroup.choice == .attachment {
            scheduledGroup.unload()
        }
        scheduledList.attachment.unload()
    }
}
