//
//  PayeeViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func loadPayeeList() async {
        guard payeeList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadPayeeList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.payeeList.data),
                load(&taskGroup, keyPath: \Self.payeeList.used),
                load(&taskGroup, keyPath: \Self.payeeList.order),
                load(&taskGroup, keyPath: \Self.payeeList.att),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        payeeList.state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.loadPayeeList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadPayeeList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadPayeeList() {
        guard payeeList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadPayeeList(main=\(Thread.isMainThread))")
        payeeList.data.unload()
        payeeList.used.unload()
        payeeList.order.unload()
        payeeList.state.loaded()
    }
}

extension ViewModel {
    func loadPayeeGroup(choice: PayeeGroupChoice) {
        guard
            let listData     = payeeList.data.readyValue,
            let listUsed     = payeeList.used.readyValue,
            let listOrder    = payeeList.order.readyValue,
            let listAtt      = payeeList.att.readyValue,
            let categoryPath = categoryList.path.readyValue
        else { return }

        guard payeeGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadPayeeGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        payeeGroup.choice = choice
        payeeGroup.groupCategory = []

        switch choice {
        case .all:
            payeeGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in PayeeGroup.groupUsed {
                let name = g ? "Used" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        case .active:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.active }
            for g in PayeeGroup.groupActive {
                let name = g ? "Active" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        case .category:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.categoryId }
            payeeGroup.groupCategory = categoryPath.path.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in payeeGroup.groupCategory {
                let name = categoryPath.path[g]
                payeeGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in PayeeGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        payeeGroup.state.loaded()
    }

    func unloadPayeeGroup() {
        payeeGroup.unload()
    }
}

extension ViewModel {
    func reloadPayeeList(_ oldData: PayeeData?, _ newData: PayeeData?) async {
        // not implemented
    }
}

extension ViewModel {
    func payeeGroupIsVisible(_ g: Int, search: PayeeSearch
    ) -> Bool? {
        guard
            let listData  = payeeList.data.readyValue,
            let groupData = payeeGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch payeeGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchPayeeGroup(search: PayeeSearch, expand: Bool = false ) {
        guard payeeGroup.state == .ready else { return }
        for g in 0 ..< payeeGroup.value.count {
            guard let isVisible = payeeGroupIsVisible(g, search: search) else { return }
            payeeGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                payeeGroup.value[g].isExpanded = true
            }
        }
    }
}

extension ViewModel {
    func updatePayee(_ data: inout PayeeData) -> String? {
        return "* not implemented"
    }

    func deletePayee(_ data: PayeeData) -> String? {
        return "* not implemented"
    }
}
