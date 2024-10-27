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
        let allOk = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            load(&taskGroup, keyPath: \Self.stockList.data)
            load(&taskGroup, keyPath: \Self.stockList.used)
            load(&taskGroup, keyPath: \Self.stockList.order)
            load(&taskGroup, keyPath: \Self.stockList.att)
            // used in EditView
            load(&taskGroup, keyPath: \Self.accountList.name)
            load(&taskGroup, keyPath: \Self.accountList.order)
            return await taskGroupOk(taskGroup)
        }
        stockList.state.loaded(ok: allOk)
        if allOk {
            log.info("INFO: ViewModel.loadStockList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadStockList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadStockList() {
        guard stockList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadStockList(main=\(Thread.isMainThread))")
        stockList.data.unload()
        stockList.used.unload()
        stockList.order.unload()
        stockList.state.unloaded()
    }
}

extension ViewModel {
    func loadStockGroup(choice: StockGroupChoice) {
        guard
            let listData    = stockList.data.readyValue,
            let listUsed    = stockList.used.readyValue,
            let listOrder   = stockList.order.readyValue,
            let listAtt     = stockList.att.readyValue,
            let accountName = accountList.name.readyValue
        else { return }

        guard stockGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadStockGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        stockGroup.choice = choice
        stockGroup.groupAccount = []

        switch choice {
        case .all:
            stockGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in StockGroup.groupUsed {
                let name = g ? "Used" : "Other"
                stockGroup.append(name, dict[g] ?? [], true, g)
            }
        case .account:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.accountId }
            stockGroup.groupAccount = accountName.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in stockGroup.groupAccount {
                let name = accountName[g]
                stockGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
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
            let listData  = stockList.data.readyValue,
            let groupData = stockGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch stockGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
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
