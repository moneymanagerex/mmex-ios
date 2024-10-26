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
            load(queue: &queue, keyPath: \Self.stockList.att)
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
        guard
            stockList.state       == .ready,
            stockList.data.state  == .ready,
            stockList.order.state == .ready,
            stockList.used.state  == .ready,
            stockList.att.state   == .ready
        else { return }

        guard stockGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadStockGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        stockGroup.choice = choice
        stockGroup.groupAccount = []

        let dataDict  = stockList.data.value
        let dataOrder = stockList.order.value
        let dataUsed  = stockList.used.value
        let dataAtt   = stockList.att.value

        switch choice {
        case .all:
            stockGroup.append("All", dataOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: dataOrder) { dataUsed.contains($0) }
            for g in StockGroup.groupUsed {
                let name = g ? "Used" : "Other"
                stockGroup.append(name, dict[g] ?? [], true, g)
            }
        case .account:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.accountId }
            stockGroup.groupAccount = env.accountCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in stockGroup.groupAccount {
                let name = env.accountCache[g]?.name
                stockGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: dataOrder) { dataAtt[$0]?.count ?? 0 > 0 }
            for g in StockGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                stockGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        stockGroup.state.loaded()
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
