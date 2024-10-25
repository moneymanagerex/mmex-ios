//
//  AssetViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

enum AssetGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AssetGroup: RepositoryGroupProtocol {
    typealias MainRepository = AssetRepository
    typealias GroupChoice    = AssetGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState = .init()
    var value: ValueType = []
}

struct AssetSearch: RepositorySearchProtocol {
    var area: [RepositorySearchArea<AssetData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}

extension RepositoryViewModel {
    func loadAssetList() async {
        guard assetList.state.loading() else { return }
        log.trace("DEBUG: RepositoryViewModel.loadAssetList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.assetData)
            load(queue: &queue, keyPath: \Self.assetOrder)
            load(queue: &queue, keyPath: \Self.assetUsed)
            return await allOk(queue: queue)
        }
        assetList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadAssetList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadAssetList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadAssetList() {
        guard assetList.state.unloading() else { return }
        log.trace("DEBUG: RepositoryViewModel.unloadAssetList(main=\(Thread.isMainThread))")
        assetData.unload()
        assetOrder.unload()
        assetUsed.unload()
        assetList.state.unloaded()
    }
}

extension RepositoryViewModel {
    func loadAssetGroup(choice: AssetGroupChoice) {
    }

    func unloadAssetGroup() {
        assetGroup.unload()
    }
}

extension RepositoryViewModel {
    func reloadAssetList(_ oldData: AssetData?, _ newData: AssetData?) async {
    }
}

extension RepositoryViewModel {
    func assetGroupIsVisible(_ g: Int, search: AssetSearch
    ) -> Bool? {
        guard
            assetData.state  == .ready,
            assetGroup.state == .ready
        else { return nil }

        let dataDict  = assetData.value
        let groupData = assetGroup.value

        if search.isEmpty {
            return switch assetGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(dataDict[$0]!) }) != nil
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
