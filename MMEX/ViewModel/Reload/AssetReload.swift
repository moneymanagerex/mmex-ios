//
//  AssetReload.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadAssetList(_ oldData: AssetData?, _ newData: AssetData?) async {
        log.trace("DEBUG: ViewModel.reloadAssetList(main=\(Thread.isMainThread))")

        if
            let newCurrency = newData?.currencyId,
            let currencyInfo = currencyList.info.readyValue,
            currencyInfo[newCurrency] == nil
        {
            if
                let currencyData = currencyList.data.readyValue,
                let newCurrencyData = currencyData[newCurrency]
            {
                if currencyList.info.state.unloading() {
                    currencyList.info.value[newCurrency] = CurrencyInfo(newCurrencyData)
                    currencyList.info.state.loaded()
                }
            } else {
                currencyList.info.unload()
            }
        }

        if let currencyUsed = currencyList.used.readyValue {
            let oldCurrency = oldData?.currencyId
            let newCurrency = newData?.currencyId
            if let oldCurrency, newCurrency != oldCurrency {
                currencyList.used.unload()
            } else if let newCurrency, !currencyUsed.contains(newCurrency) {
                if currencyList.used.state.unloading() {
                    currencyList.used.value.insert(newCurrency)
                    currencyList.used.state.loaded()
                }
            }
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = assetGroup.readyValue?.map { $0.isExpanded }
        let currencyIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: assetGroup.groupCurrency.enumerated().map { ($0.1, $0.0) }
        )

        unloadAssetGroup()
        assetList.unload()

        if (oldData != nil) != (newData != nil) {
            assetList.count.unload()
        }

        if assetList.data.state.unloading() {
            if let newData {
                assetList.data.value[newData.id] = newData
            } else if let oldData {
                assetList.data.value[oldData.id] = nil
            }
            assetList.data.state.loaded()
        }

        assetList.order.unload()

        if let _ = newData {
            assetList.att.unload()
        } else if let oldData {
            if assetList.att.state.unloading() {
                assetList.att.value[oldData.id] = nil
                assetList.att.state.loaded()
            }
        }

        await loadAssetList()
        loadAssetGroup(choice: assetGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch assetGroup.choice {
        case .currency:
            for (g, currencyId) in assetGroup.groupCurrency.enumerated() {
                guard let i = currencyIndex[currencyId] else { continue }
                assetGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if assetGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    assetGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadAssetList(main=\(Thread.isMainThread))")
    }
}
