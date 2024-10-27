//
//  CategoryViewModel.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func loadCategoryList() async {
        guard categoryList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCategoryList(main=\(Thread.isMainThread))")
        var queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.categoryList.data)
            load(queue: &queue, keyPath: \Self.categoryList.used)
            return await allOk(queue: queue)
        }

        if queueOk { queueOk = await load(
            eval: { self.evalCategoryPath() }, keyPath: \Self.categoryList.path
        ) }

        if queueOk { queueOk = await load(
            eval: { self.evalCategoryOrder() }, keyPath: \Self.categoryList.order
        ) }

        categoryList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: ViewModel.loadCategoryList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadCategoryList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadCategoryList() {
        guard categoryList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadCategoryList(main=\(Thread.isMainThread))")
        categoryList.data.unload()
        categoryList.used.unload()
        categoryList.state.unloaded()
    }
}

extension ViewModel {
    func loadCategoryGroup(choice: CategoryGroupChoice) {
        guard
            let listData  = categoryList.data.readyValue,
            let listUsed  = categoryList.used.readyValue,
            let listOrder = categoryList.order.readyValue
        else { return }

        guard categoryGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCategoryGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        categoryGroup.choice = choice

        switch choice {
        case .all:
            categoryGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in CategoryGroup.groupUsed {
                let name = g ? "Used" : "Other"
                categoryGroup.append(name, dict[g] ?? [], true, g)
            }
        case .active:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.active }
            for g in CategoryGroup.groupActive {
                let name = g ? "Active" : "Other"
                categoryGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        categoryGroup.state.loaded()
    }

    func unloadCategoryGroup() {
        categoryGroup.unload()
    }
}

extension ViewModel {
    func reloadCategoryList(_ oldData: CategoryData?, _ newData: CategoryData?) async {
    }
}

extension ViewModel {
    func categoryGroupIsVisible(_ g: Int, search: CategorySearch
    ) -> Bool? {
        guard
            let listData  = categoryList.data.readyValue,
            let groupData = categoryGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch categoryGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(listData[$0]!) }) != nil
    }

    func searchCategoryGroup(search: CategorySearch, expand: Bool = false ) {
        guard categoryGroup.state == .ready else { return }
        for g in 0 ..< categoryGroup.value.count {
            guard let isVisible = categoryGroupIsVisible(g, search: search) else { return }
            categoryGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                categoryGroup.value[g].isExpanded = true
            }
        }
    }
}

extension ViewModel {
    func updateCategory(_ data: inout CategoryData) -> String? {
        return "* not implemented"
    }

    func deleteCategory(_ data: CategoryData) -> String? {
        return "* not implemented"
    }
}
