//
//  AssetViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func loadAssetList() async {
        guard assetList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAssetList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.assetList.data)
            load(queue: &queue, keyPath: \Self.assetList.used)
            load(queue: &queue, keyPath: \Self.assetList.order)
            load(queue: &queue, keyPath: \Self.assetList.att)
            // used in EditView
            load(queue: &queue, keyPath: \Self.currencyList.name)
            load(queue: &queue, keyPath: \Self.currencyList.order)
            return await allOk(queue: queue)
        }
        assetList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: ViewModel.loadAssetList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadAssetList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadAssetList() {
        guard assetList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadAssetList(main=\(Thread.isMainThread))")
        assetList.data.unload()
        assetList.used.unload()
        assetList.order.unload()
        assetList.state.unloaded()
    }
}

extension ViewModel {
    func loadAssetGroup(choice: AssetGroupChoice) {
        guard
            let listData     = assetList.data.readyValue,
            let listUsed     = assetList.used.readyValue,
            let listOrder    = assetList.order.readyValue,
            let listAtt      = assetList.att.readyValue,
            let currencyName = currencyList.name.readyValue
        else { return }

        guard assetGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAssetGroup(\(choice.rawValue), main=\(Thread.isMainThread))")

        assetGroup.choice = choice
        assetGroup.groupCurrency = []

        switch choice {
        case .all:
            assetGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in AssetGroup.groupUsed {
                let name = g ? "Used" : "Other"
                assetGroup.append(name, dict[g] ?? [], true, g)
            }
        case .status:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.status }
            for g in AssetGroup.groupStatus {
                assetGroup.append(g.rawValue, dict[g] ?? [], true, true)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in AssetGroup.groupType {
                assetGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.currencyId }
            assetGroup.groupCurrency = currencyName.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in assetGroup.groupCurrency {
                let name = currencyName[g]
                assetGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in AssetGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                assetGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        assetGroup.state.loaded()
    }

    func unloadAssetGroup() {
        assetGroup.unload()
    }
}

extension ViewModel {
    func reloadAssetList(_ oldData: AssetData?, _ newData: AssetData?) async {
    }
}

extension ViewModel {
    func assetGroupIsVisible(_ g: Int, search: AssetSearch
    ) -> Bool? {
        guard
            let listData  = assetList.data.readyValue,
            let groupData = assetGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch assetGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(listData[$0]!) }) != nil
    }

    func searchAssetGroup(search: AssetSearch, expand: Bool = false ) {
        guard assetGroup.state == .ready else { return }
        for g in 0 ..< assetGroup.value.count {
            guard let isVisible = assetGroupIsVisible(g, search: search) else { return }
            assetGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                assetGroup.value[g].isExpanded = true
            }
        }
    }
}

extension ViewModel {
    func updateAsset(_ data: inout AssetData) -> String? {
        return "* not implemented"
    }

    func deleteAsset(_ data: AssetData) -> String? {
        return "* not implemented"
    }
}
