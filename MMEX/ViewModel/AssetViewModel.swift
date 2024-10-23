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
    typealias MainRepository = AssetRepository

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[RepositoryGroupData]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []
}

extension RepositoryViewModel {
    func loadAssetList() async {
        log.trace("DEBUG: RepositoryViewModel.loadAssetList(main=\(Thread.isMainThread))")
        guard case .idle = assetList.state else { return }
        assetList.state = .loading
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.assetData)
            load(queue: &queue, keyPath: \Self.assetOrder)
            load(queue: &queue, keyPath: \Self.assetUsed)
            return await allOk(queue: queue)
        }
        assetList.state = queueOk ? .ready(()) : .error("Cannot load.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadAssetList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadAssetList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadAssetList() {
        log.trace("DEBUG: RepositoryViewModel.unloadAssetList(main=\(Thread.isMainThread))")
        if case .loading = assetList.state { return }
        assetList.state = .loading
        assetData.unload()
        assetOrder.unload()
        assetUsed.unload()
        assetList.state = .idle
    }
}

extension RepositoryViewModel {
    func unloadAssetGroup() {
        log.trace("DEBUG: RepositoryViewModel.unloadAssetGroup(main=\(Thread.isMainThread))")
        if case .loading = assetGroup.state { return }
        assetGroup.state = .loading
        assetGroup.isVisible  = []
        assetGroup.isExpanded = []
        assetGroup.state = .idle
    }
}
