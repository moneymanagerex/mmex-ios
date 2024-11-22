//
//  CategoryReload.swift
//  MMEX
//
//  2024-11-18: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadCategory(_ oldData: CategoryData?, _ newData: CategoryData?) async {
        log.trace("DEBUG: ViewModel.reloadCategory(main=\(Thread.isMainThread))")
        
        // TODO: save isExpanded
        
        unloadCategoryGroup()
        categoryList.unload()
        
        if (oldData != nil) != (newData != nil) {
            categoryList.count.unload()
        }
        
        categoryList.evalPath.unload()
        categoryList.evalUsed.unload()
        categoryList.evalTree.unload()
        
        if categoryList.data.state.unloading() {
            if let newData {
                categoryList.data.value[newData.id] = newData
            } else if let oldData {
                categoryList.data.value[oldData.id] = nil
            }
            categoryList.data.state.loaded()
        }
        
        categoryList.order.unload()
        
        await loadCategoryList()
        loadCategoryGroup(choice: categoryGroup.choice)
        
        // TODO: restore isExpanded
        
        log.info("INFO: ViewModel.reloadCategory(main=\(Thread.isMainThread))")
    }

    func reloadCategoryUsed(_ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadCategoryUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0)")
        guard let categoryUsed = categoryList.used.readyValue else { return }
        if let oldId, newId != oldId {
            if categoryGroup.choice == .used || categoryGroup.choice == .notUsed {
                unloadCategoryGroup()
            }
            categoryList.unload()
            categoryList.used.unload()
        } else if let newId, !categoryUsed.contains(newId) {
            if categoryGroup.choice == .used || categoryGroup.choice == .notUsed {
                unloadCategoryGroup()
            }
            if categoryList.used.state.unloading() {
                categoryList.used.value.insert(newId)
                categoryList.used.state.loaded()
            }
        }
    }
}
