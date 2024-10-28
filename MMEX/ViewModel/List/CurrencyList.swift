//
//  CurrencyList.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct CurrencyList: ListProtocol {
    typealias MainRepository = CurrencyRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var name  : LoadMainName<MainRepository>  = .init { $0[MainRepository.col_name] }
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])

    typealias UH = CurrencyHistoryRepository
    var history : LoadAuxData<MainRepository, UH> = .init(
        mainId: { DataId($0[UH.col_currencyId]) },
        auxTable: UH.table.order(UH.col_currDate)
    )
}

extension ViewModel {
    func loadCurrencyList() async {
        guard currencyList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCurrencyList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.currencyList.data),
                load(&taskGroup, keyPath: \Self.currencyList.used),
                load(&taskGroup, keyPath: \Self.currencyList.order),
                load(&taskGroup, keyPath: \Self.currencyList.history),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        currencyList.state.loaded(ok: ok)
        if ok {
            log.info("INFO: CurrencyList.load(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: CurrencyList.load(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadCurrencyList() {
        guard currencyList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadCurrencyList(main=\(Thread.isMainThread))")
        currencyList.data.unload()
        currencyList.used.unload()
        currencyList.order.unload()
        currencyList.history.unload()
        currencyList.state.unloaded()
    }
}
