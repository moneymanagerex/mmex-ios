//
//  CurrencyViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func loadCurrencyList() async {
        guard currencyList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCurrencyList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyList.data)
            load(queue: &queue, keyPath: \Self.currencyList.order)
            load(queue: &queue, keyPath: \Self.currencyList.used)
            return await allOk(queue: queue)
        }
        currencyList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: CurrencyList.load(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: CurrencyList.load(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadCurrencyList() {
        guard currencyList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadCurrencyList(main=\(Thread.isMainThread))")
        currencyList.data.unload()
        currencyList.order.unload()
        currencyList.used.unload()
        currencyList.state.unloaded()
    }
}

extension ViewModel {
    func loadCurrencyGroup(choice: CurrencyGroupChoice) {
        // TODO
    }

    func unloadCurrencyGroup() {
        currencyGroup.unload()
    }
}

extension ViewModel {
    func reloadCurrencyList(_ oldData: CurrencyData?, _ newData: CurrencyData?) async {
    }
}

extension ViewModel {
    func currencyGroupIsVisible(_ g: Int, search: CurrencySearch
    ) -> Bool? {
        guard
            currencyList.data.state  == .ready,
            currencyGroup.state == .ready
        else { return nil }

        let dataDict  = currencyList.data.value
        let groupData = currencyGroup.value

        if search.isEmpty {
            return switch currencyGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(dataDict[$0]!) }) != nil
    }

    func searchCurrencyGroup(search: CurrencySearch, expand: Bool = false ) {
        guard currencyGroup.state == .ready else { return }
        for g in 0 ..< currencyGroup.value.count {
            guard let isVisible = currencyGroupIsVisible(g, search: search) else { return }
            currencyGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                currencyGroup.value[g].isExpanded = true
            }
        }
    }
}
