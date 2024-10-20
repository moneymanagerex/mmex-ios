//
//  AssetViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension RepositoryViewModel {
    func loadAssetList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.assetDict)
            load(queue: &queue, keyPath: \Self.assetOrder)
            load(queue: &queue, keyPath: \Self.assetUsed)
            return await allOk(queue: queue)
        }
        assetList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadAssetList() {
        assetDict.unload()
        assetOrder.unload()
        assetUsed.unload()
        assetList.state = .idle
    }
}
