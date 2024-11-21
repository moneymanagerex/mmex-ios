//
//  StockReload.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadStockList(_ oldData: StockData?, _ newData: StockData?) async {
        log.trace("DEBUG: ViewModel.reloadStockList(main=\(Thread.isMainThread))")

        var accountChanged = false
        if let accountUsed = accountList.used.readyValue {
            let oldAccountId = oldData?.accountId
            let newAccountId = newData?.accountId
            if let oldAccountId, newAccountId != oldAccountId {
                accountList.used.unload()
                accountChanged = true
            } else if let newAccountId, !accountUsed.contains(newAccountId) {
                if accountList.used.state.unloading() {
                    accountList.used.value.insert(newAccountId)
                    accountList.used.state.loaded()
                    accountChanged = true
                }
            }
        }
        if accountChanged {
            unloadAccountGroup()
            accountList.unload()
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = stockGroup.readyValue?.map { $0.isExpanded }
        let accountIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: stockGroup.groupAccount.enumerated().map { ($0.1, $0.0) }
        )

        unloadStockGroup()
        stockList.unload()

        if (oldData != nil) != (newData != nil) {
            stockList.count.unload()
        }

        if stockList.data.state.unloading() {
            if let newData {
                stockList.data.value[newData.id] = newData
            } else if let oldData {
                stockList.data.value[oldData.id] = nil
            }
            stockList.data.state.loaded()
        }

        stockList.order.unload()

        if let _ = newData {
            stockList.att.unload()
        } else if let oldData {
            if stockList.att.state.unloading() {
                stockList.att.value[oldData.id] = nil
                stockList.att.state.loaded()
            }
        }

        await loadStockList()
        loadStockGroup(choice: stockGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch stockGroup.choice {
        case .account:
            for (g, accountId) in stockGroup.groupAccount.enumerated() {
                guard let i = accountIndex[accountId] else { continue }
                stockGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if stockGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    stockGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadStockList(main=\(Thread.isMainThread))")
    }
}
