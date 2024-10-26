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
            load(queue: &queue, keyPath: \Self.assetList.order)
            load(queue: &queue, keyPath: \Self.assetList.used)
            load(queue: &queue, keyPath: \Self.assetList.att)
            return await allOk(queue: queue)
        }
        assetList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: ViewModel.loadAssetList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadAssetList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadAssetList() {
        guard assetList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadAssetList(main=\(Thread.isMainThread))")
        assetList.data.unload()
        assetList.order.unload()
        assetList.used.unload()
        assetList.state.unloaded()
    }
}

extension ViewModel {
    func loadAssetGroup(choice: AssetGroupChoice) {
        guard
            assetList.state       == .ready,
            assetList.data.state  == .ready,
            assetList.order.state == .ready,
            assetList.used.state  == .ready,
            assetList.att.state   == .ready
        else { return }

        guard assetGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAssetGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        assetGroup.choice = choice
        assetGroup.groupCurrency = []

        let dataDict  = assetList.data.value
        let dataOrder = assetList.order.value
        let dataUsed  = assetList.used.value
        let dataAtt   = assetList.att.value

        switch choice {
        case .all:
            assetGroup.append("All", dataOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: dataOrder) { dataUsed.contains($0) }
            for g in AssetGroup.groupUsed {
                let name = g ? "Used" : "Other"
                assetGroup.append(name, dict[g] ?? [], true, g)
            }
        case .status:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.status }
            for g in AssetGroup.groupStatus {
                assetGroup.append(g.rawValue, dict[g] ?? [], true, g == .open)
            }
        case .type:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.type }
            for g in AssetGroup.groupType {
                assetGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: dataOrder) { dataDict[$0]!.currencyId }
            assetGroup.groupCurrency = env.currencyCache.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in assetGroup.groupCurrency {
                let name = env.currencyCache[g]?.name
                assetGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: dataOrder) { dataAtt[$0]?.count ?? 0 > 0 }
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
            assetList.data.state == .ready,
            assetGroup.state     == .ready
        else { return nil }

        let listData  = assetList.data.value
        let groupData = assetGroup.value

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
