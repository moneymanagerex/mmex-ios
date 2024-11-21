//
//  CategoryReload.swift
//  MMEX
//
//  2024-11-18: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadCategoryList(_ oldData: CategoryData?, _ newData: CategoryData?) async {
        log.trace("DEBUG: ViewModel.reloadCategoryList(main=\(Thread.isMainThread))")

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

        await reloadCategoryList()
        loadCategoryGroup(choice: categoryGroup.choice)

        // TODO: restore isExpanded

        log.info("INFO: ViewModel.reloadCategoryList(main=\(Thread.isMainThread))")
    }
}
