//
//  StockReload.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadStock(_ pref: Preference, _ oldData: StockData?, _ newData: StockData?) async {
        log.trace("DEBUG: ViewModel.reloadStock(main=\(Thread.isMainThread))")

        reloadAccountUsed(pref, oldData?.accountId, newData?.accountId)

        // save isExpanded
        let groupIsExpanded: [Bool]? = stockGroup.readyValue?.map { $0.isExpanded }
        let accountIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: stockGroup.groupAccount.enumerated().map { ($0.1, $0.0) }
        )

        unloadStockGroup()
        stockList.unloadNone()

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

        await loadStockList(pref)
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

        log.info("INFO: ViewModel.reloadStock(main=\(Thread.isMainThread))")
    }

    func reloadStockUsed(_ pref: Preference, _ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadStockUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        if let oldId, newId != oldId {
            if stockGroup.choice == .used {
                unloadStockGroup()
            }
            stockList.used.unload()
        } else if
            let stockUsed = stockList.used.readyValue,
            let newId, !stockUsed.contains(newId)
        {
            if stockGroup.choice == .used {
                unloadStockGroup()
            }
            if stockList.used.state.unloading() {
                stockList.used.value.insert(newId)
                stockList.used.state.loaded()
            }
        }
    }

    func reloadStockAtt(_ pref: Preference) {
        log.trace("DEBUG: ViewModel.reloadStockAtt(main=\(Thread.isMainThread))")
        if stockGroup.choice == .attachment {
            unloadStockGroup()
        }
        stockList.att.unload()
    }
}
