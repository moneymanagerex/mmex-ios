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

    var state : LoadState                         = .init()
    var count : LoadMainCount<MainRepository>     = .init()
    var data  : LoadMainData<MainRepository>      = .init()
    var used  : LoadMainUsed<MainRepository>      = .init()
    var order : LoadMainOrder<MainRepository>     = .init(order: [MainRepository.col_name])

    var attachment : LoadAuxAttachment<MainRepository> = .init()
}

extension StockList {
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
    func loadStockList(_ pref: Preference) async {
        guard stockList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.stockList.data),
                load(pref, &taskGroup, keyPath: \Self.stockList.used),
                load(pref, &taskGroup, keyPath: \Self.stockList.order),
                load(pref, &taskGroup, keyPath: \Self.stockList.attachment),
                // auxiliary
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        stockList.loaded(ok: ok)
    }
}
