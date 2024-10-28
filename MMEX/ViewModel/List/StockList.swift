//
//  StockList.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct StockList: ListProtocol {
    typealias MainRepository = StockRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var att   : LoadAuxAtt<MainRepository>    = .init()
}

extension ViewModel {
    func loadStockList() async {
        guard stockList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadStockList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.stockList.data),
                load(&taskGroup, keyPath: \Self.stockList.used),
                load(&taskGroup, keyPath: \Self.stockList.order),
                load(&taskGroup, keyPath: \Self.stockList.att),
                // used in EditView
                load(&taskGroup, keyPath: \Self.accountList.data),
                load(&taskGroup, keyPath: \Self.accountList.order),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        stockList.state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.loadStockList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadStockList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadStockList() {
        guard stockList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadStockList(main=\(Thread.isMainThread))")
        stockList.data.unload()
        stockList.used.unload()
        stockList.order.unload()
        stockList.att.unload()
        stockList.state.unloaded()
    }
}
