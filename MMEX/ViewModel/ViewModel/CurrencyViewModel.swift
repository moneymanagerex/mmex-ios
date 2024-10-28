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
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.currencyList.data),
                load(&taskGroup, keyPath: \Self.currencyList.used),
                load(&taskGroup, keyPath: \Self.currencyList.order),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        currencyList.state.loaded(ok: ok)
        if ok {
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
        log.trace("DEBUG: ViewModel.reloadCurrencyList(main=\(Thread.isMainThread))")

        // env.currencyCache contains only used currencies
        if let _ = oldData, let newData {
            if env.currencyCache[newData.id] != nil {
                env.loadCurrency()
            }
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = currencyGroup.readyValue?.map { $0.isExpanded }

        unloadCurrencyGroup()
        currencyList.state.unload()

        if (oldData != nil) != (newData != nil) {
            manageList.unload()
            currencyList.count.unload()
        }

        if currencyList.data.state.unloading() {
            if let newData {
                currencyList.data.value[newData.id] = newData
            } else if let oldData {
                currencyList.data.value[oldData.id] = nil
            }
            currencyList.data.state.loaded()
        }

        if currencyList.name.state.unloading() {
            if let newData {
                currencyList.name.value[newData.id] = newData.name
            } else if let oldData {
                currencyList.name.value[oldData.id] = nil
            }
            currencyList.name.state.loaded()
        }

        accountList.state.unload()
        currencyList.order.unload()

        await loadCurrencyList()
        loadCurrencyGroup(choice: currencyGroup.choice)

        // restore isExpanded
        if let groupIsExpanded, currencyGroup.value.count == groupIsExpanded.count {
            for g in 0 ..< groupIsExpanded.count {
                currencyGroup.value[g].isExpanded = groupIsExpanded[g]
            }
        }
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
        if data.name.isEmpty {
            return "Name is empty"
        }
        if data.symbol.isEmpty {
            return "Symbol is empty"
        }

        guard let u = U(env) else {
            return "* Database is not available"
        }

        guard let dataName = u.selectId(from: U.table.filter(
            U.table[U.col_id] == Int64(data.id) ||
            U.table[U.col_name] == data.name ||
            U.table[U.col_symbol] == data.symbol
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id <= 0 ? 0 : 1) else {
            return "Currency \(data.name) already exists"
        }

        if data.id <= 0 {
            guard u.insert(&data) else {
                return "* Cannot create new currency"
            }
        } else {
            guard u.update(data) else {
                return "* Cannot update currency #\(data.id)"
            }
        }

        return nil
    }

    func deleteCurrency(_ data: CurrencyData) -> String? {
        guard let currencyUsed = currencyList.used.readyValue else {
            return "* currencyUsed is not loaded"
        }
        if currencyUsed.contains(data.id) {
            return "* Currency #\(data.id) is used"
        }
        // TODO: check base currency

        guard let u = U(env) else {
            return "* Database is not available"
        }

        guard u.delete(data) else {
            return "* Cannot delete currency #\(data.id)"
        }

        return nil
    }
}
