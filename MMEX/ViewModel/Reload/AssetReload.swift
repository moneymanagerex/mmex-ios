//
//  AssetReload.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadAsset(_ oldData: AssetData?, _ newData: AssetData?) async {
        log.trace("DEBUG: ViewModel.reloadAsset(main=\(Thread.isMainThread))")

        reloadCurrencyUsed(oldData?.currencyId, newData?.currencyId)

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

        log.info("INFO: ViewModel.reloadAsset(main=\(Thread.isMainThread))")
    }

    func reloadAssetUsed(_ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadAssetUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        if let oldId, newId != oldId {
            if assetGroup.choice == .used {
                unloadAssetGroup()
            }
            assetList.used.unload()
        } else if
            let assetUsed = assetList.used.readyValue,
            let newId, !assetUsed.contains(newId)
        {
            if assetGroup.choice == .used {
                unloadAssetGroup()
            }
            if assetList.used.state.unloading() {
                assetList.used.value.insert(newId)
                assetList.used.state.loaded()
            }
        }
    }

    func reloadAssetAtt() {
        log.trace("DEBUG: ViewModel.reloadAssetAtt(main=\(Thread.isMainThread))")
        if assetGroup.choice == .attachment {
            unloadAssetGroup()
        }
        assetList.att.unload()
    }
}
