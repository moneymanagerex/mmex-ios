//
//  PayeeReload.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadPayee(_ pref: Preference, _ oldData: PayeeData?, _ newData: PayeeData?) async {
        log.trace("DEBUG: ViewModel.reloadPayee(main=\(Thread.isMainThread))")

        reloadCategoryUsed(pref, oldData?.categoryId, newData?.categoryId)

        // save isExpanded
        let groupIsExpanded: [Bool]? = payeeGroup.readyValue?.map { $0.isExpanded }
        let categoryIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: payeeGroup.groupCategory.enumerated().map { ($0.1, $0.0) }
        )

        unloadPayeeGroup()
        payeeList.unload()

        if (oldData != nil) != (newData != nil) {
            payeeList.count.unload()
        }

        if payeeList.data.state.unloading() {
            if let newData {
                payeeList.data.value[newData.id] = newData
            } else if let oldData {
                payeeList.data.value[oldData.id] = nil
            }
            payeeList.data.state.loaded()
        }

        payeeList.order.unload()

        if let _ = newData {
            payeeList.att.unload()
        } else if let oldData {
            if payeeList.att.state.unloading() {
                payeeList.att.value[oldData.id] = nil
                payeeList.att.state.loaded()
            }
        }

        await loadPayeeList(pref)
        loadPayeeGroup(choice: payeeGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch payeeGroup.choice {
        case .category:
            for (g, categoryId) in payeeGroup.groupCategory.enumerated() {
                guard let i = categoryIndex[categoryId] else { continue }
                payeeGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if payeeGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    payeeGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadPayee(main=\(Thread.isMainThread))")
    }

    func reloadPayeeUsed(_ pref: Preference, _ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadPayeeUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        if let oldId, newId != oldId {
            if payeeGroup.choice == .used {
                unloadPayeeGroup()
            }
            payeeList.used.unload()
        } else if
            let payeeUsed = payeeList.used.readyValue,
            let newId, !payeeUsed.contains(newId)
        {
            if payeeGroup.choice == .used {
                unloadPayeeGroup()
            }
            if payeeList.used.state.unloading() {
                payeeList.used.value.insert(newId)
                payeeList.used.state.loaded()
            }
        }
    }

    func reloadPayeeAtt(_ pref: Preference) {
        log.trace("DEBUG: ViewModel.reloadPayeeAtt(main=\(Thread.isMainThread))")
        if payeeGroup.choice == .attachment {
            unloadPayeeGroup()
        }
        payeeList.att.unload()
    }
}
