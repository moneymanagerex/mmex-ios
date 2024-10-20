//
//  AssetViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AssetGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AssetGroup: RepositoryLoadGroupProtocol {
    typealias GroupChoice    = AssetGroupChoice
    typealias RepositoryType = AssetRepository

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[[DataId]]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []
}

extension RepositoryViewModel {
    func loadAssetData() async {
        log.trace("DEBUG: RepositoryViewModel.loadAssetData(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.assetDict)
            load(queue: &queue, keyPath: \Self.assetOrder)
            load(queue: &queue, keyPath: \Self.assetUsed)
            return await allOk(queue: queue)
        }
        assetData.state = queueOk ? .ready(()) : .error("Cannot load data.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadAssetData(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadAssetData(main=\(Thread.isMainThread)): Cannot load data.")
            return
        }
    }

    func unloadAssetData() {
        log.trace("DEBUG: RepositoryViewModel.unloadAssetData(main=\(Thread.isMainThread))")
        assetDict.unload()
        assetOrder.unload()
        assetUsed.unload()
        assetData.state = .idle
    }
}

extension RepositoryViewModel {
    func unloadAssetGroup() -> Bool? {
        log.trace("DEBUG: RepositoryViewModel.unloadAssetGroup(main=\(Thread.isMainThread))")
        if case .loading = assetGroup.state { return nil }
        assetGroup.state = .idle
        assetGroup.isVisible  = []
        assetGroup.isExpanded = []
        return true
    }
}
