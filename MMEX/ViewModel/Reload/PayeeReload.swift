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

        if let categoryUsed = categoryList.used.readyValue {
            let oldCategory = oldData?.categoryId
            let newCategory = newData?.categoryId
            if let oldCategory, newCategory != oldCategory {
                categoryList.used.unload()
            } else if let newCategory, !categoryUsed.contains(newCategory) {
                if categoryList.used.state.unloading() {
                    categoryList.used.value.insert(newCategory)
                    categoryList.used.state.loaded()
                }
            }
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

        if payeeList.name.state.unloading() {
            if let newData {
                payeeList.name.value[newData.id] = newData.name
            } else if let oldData {
                payeeList.name.value[oldData.id] = nil
            }
            payeeList.name.state.loaded()
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