//
//  AssetList.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct AssetList: ListProtocol {
    typealias MainRepository = AssetRepository

    var state : LoadState                         = .init()
    var count : LoadMainCount<MainRepository>     = .init()
    var data  : LoadMainData<MainRepository>      = .init()
    var used  : LoadMainUsed<MainRepository>      = .init()
    var order : LoadMainOrder<MainRepository>     = .init(order: [MainRepository.col_name])

    var attachment : LoadAuxAttachment<MainRepository> = .init()
}

extension AssetList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        attachment.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadAssetList(_ pref: Preference) async {
        guard assetList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.assetList.data),
                load(pref, &taskGroup, keyPath: \Self.assetList.used),
                load(pref, &taskGroup, keyPath: \Self.assetList.order),
                load(pref, &taskGroup, keyPath: \Self.assetList.attachment),
                // auxiliary
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.currencyList.name),
                load(pref, &taskGroup, keyPath: \Self.currencyList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        assetList.loaded(ok: ok)
    }
}
