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
