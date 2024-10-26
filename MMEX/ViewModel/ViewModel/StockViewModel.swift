//
//  StockViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func loadStockList() async {
        guard stockList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadStockList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.stockList.data)
            load(queue: &queue, keyPath: \Self.stockList.order)
            load(queue: &queue, keyPath: \Self.stockList.used)
            return await allOk(queue: queue)
        }
        stockList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: ViewModel.loadStockList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadStockList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadStockList() {
        guard stockList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadStockList(main=\(Thread.isMainThread))")
        stockList.data.unload()
        stockList.order.unload()
        stockList.used.unload()
        stockList.state.unloaded()
    }
}

extension ViewModel {
    func loadStockGroup(choice: StockGroupChoice) {
    }

    func unloadStockGroup() {
        stockGroup.unload()
    }
}

extension ViewModel {
    func reloadStockList(_ oldData: StockData?, _ newData: StockData?) async {
    }
}

extension ViewModel {
    func stockGroupIsVisible(_ g: Int, search: StockSearch
    ) -> Bool? {
        guard
            stockList.data.state == .ready,
            stockGroup.state     == .ready
        else { return nil }

        let listData  = stockList.data.value
        let groupData = stockGroup.value

        if search.isEmpty {
            return switch stockGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(listData[$0]!) }) != nil
    }

    func searchStockGroup(search: StockSearch, expand: Bool = false ) {
        guard stockGroup.state == .ready else { return }
        for g in 0 ..< stockGroup.value.count {
            guard let isVisible = stockGroupIsVisible(g, search: search) else { return }
            stockGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                stockGroup.value[g].isExpanded = true
            }
        }
    }
}

extension ViewModel {
    func updateStock(_ data: inout StockData) -> String? {
        return "* not implemented"
    }

    func deleteStock(_ data: StockData) -> String? {
        return "* not implemented"
    }
}
