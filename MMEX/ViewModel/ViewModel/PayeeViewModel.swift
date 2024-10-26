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
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeList.data)
            load(queue: &queue, keyPath: \Self.payeeList.order)
            load(queue: &queue, keyPath: \Self.payeeList.used)
            load(queue: &queue, keyPath: \Self.payeeList.att)
            return await allOk(queue: queue)
        }
        payeeList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: ViewModel.loadPayeeList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadPayeeList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadPayeeList() {
        guard payeeList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadPayeeList(main=\(Thread.isMainThread))")
        payeeList.data.unload()
        payeeList.order.unload()
        payeeList.used.unload()
        payeeList.state.loaded()
    }
}

extension ViewModel {
    func loadPayeeGroup(choice: PayeeGroupChoice) {
        guard
            payeeList.state       == .ready,
            payeeList.data.state  == .ready,
            payeeList.order.state == .ready,
            payeeList.used.state  == .ready,
            payeeList.att.state   == .ready
        else { return }

        guard payeeGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadPayeeGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        payeeGroup.choice = choice
        payeeGroup.groupCategory = []

        let dataDict  = payeeList.data.value
        let dataOrder = payeeList.order.value
        let dataUsed  = payeeList.used.value
        let dataAtt   = payeeList.att.value
        // TODO
        let categoryData: [DataId: CategoryData] = [:]

        switch choice {
        case .all:
            payeeGroup.append("All", dataOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: dataOrder) { dataUsed.contains($0) }
            for g in PayeeGroup.groupUsed {
                let name = g ? "Used" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        case .active:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.active }
            for g in PayeeGroup.groupActive {
                let name = g ? "Active" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        case .category:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.categoryId }
            payeeGroup.groupCategory = categoryData.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in payeeGroup.groupCategory {
                let name = categoryData[g]?.name
                payeeGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: dataOrder) { dataAtt[$0]?.count ?? 0 > 0 }
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
    }
}

extension ViewModel {
    func payeeGroupIsVisible(_ g: Int, search: PayeeSearch
    ) -> Bool? {
        guard
            payeeList.data.state == .ready,
            payeeGroup.state     == .ready
        else { return nil }

        let listData  = payeeList.data.value
        let groupData = payeeGroup.value

        if search.isEmpty {
            return switch payeeGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(listData[$0]!) }) != nil
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
