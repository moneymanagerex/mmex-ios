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

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var name  : LoadMainName<MainRepository>  = .init { $0[MainRepository.col_name] }
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var att   : LoadAuxAtt<MainRepository>    = .init()
}

extension ViewModel {
    func loadAssetList() async {
        guard assetList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAssetList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.assetList.data),
                load(&taskGroup, keyPath: \Self.assetList.used),
                load(&taskGroup, keyPath: \Self.assetList.order),
                load(&taskGroup, keyPath: \Self.assetList.att),
                // used in EditView
                load(&taskGroup, keyPath: \Self.currencyList.name),
                load(&taskGroup, keyPath: \Self.currencyList.order),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        assetList.state.loaded(ok: ok)
        if ok {
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
        assetList.att.unload()
        assetList.state.unloaded()
    }
}
