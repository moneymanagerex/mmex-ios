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
        let allOk = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            load(&taskGroup, keyPath: \Self.currencyList.data)
            load(&taskGroup, keyPath: \Self.currencyList.used)
            load(&taskGroup, keyPath: \Self.currencyList.order)
            return await taskGroupOk(taskGroup)
        }
        currencyList.state.loaded(ok: allOk)
        if allOk {
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
        currencyList.used.unload()
        currencyList.order.unload()
        currencyList.state.unloaded()
    }
}

extension ViewModel {
    func loadCurrencyGroup(choice: CurrencyGroupChoice) {
        guard
            let listData  = currencyList.data.readyValue,
            let listUsed  = currencyList.used.readyValue,
            let listOrder = currencyList.order.readyValue
        else { return }

        guard currencyGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCurrencyGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        currencyGroup.choice = choice

        switch choice {
        case .all:
            currencyGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in CurrencyGroup.groupUsed {
                let name = g ? "Used" : "Other"
                currencyGroup.append(name, dict[g] ?? [], true, g)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in CurrencyGroup.groupType {
                currencyGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        }

        currencyGroup.state.loaded()
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
            let listData  = currencyList.data.readyValue,
            let groupData = currencyGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch currencyGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
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

extension ViewModel {
    func updateCurrency(_ data: inout CurrencyData) -> String? {
        return "* not implemented"
    }

    func deleteCurrency(_ data: CurrencyData) -> String? {
        return "* not implemented"
    }
}
