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
