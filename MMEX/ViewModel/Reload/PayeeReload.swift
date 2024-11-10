//
//  PayeeReload.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadPayeeList(_ oldData: PayeeData?, _ newData: PayeeData?) async {
        log.trace("DEBUG: ViewModel.reloadPayeeList(main=\(Thread.isMainThread))")

        var categoryChanged = false
        if let categoryUsed = categoryList.used.readyValue {
            let oldCategoryId = oldData?.categoryId
            let newCategoryId = newData?.categoryId
            if let oldCategoryId, newCategoryId != oldCategoryId {
                categoryList.used.unload()
                categoryChanged = true
            } else if let newCategoryId, !categoryUsed.contains(newCategoryId) {
                if categoryList.used.state.unloading() {
                    categoryList.used.value.insert(newCategoryId)
                    categoryList.used.state.loaded()
                    categoryChanged = true
                }
            }
        }
        if categoryChanged {
            unloadCategoryGroup()
            categoryList.unload()
        }

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

        await loadPayeeList()
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

        log.info("INFO: ViewModel.reloadPayeeList(main=\(Thread.isMainThread))")
    }
}
