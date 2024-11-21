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

    var info  : LoadMainValue<MainRepository, CurrencyInfo> = .init(
        table : MainRepository.filterUsed(MainRepository.table),
        with  : { row in CurrencyInfo(MainRepository.fetchData(row)) }
    )

    typealias UH = CurrencyHistoryRepository
    var history : LoadAuxData<MainRepository, UH> = .init(
        mainId: { DataId($0[UH.col_currencyId]) },
        auxTable: UH.table.order(UH.col_currDate)
    )
}

extension ViewModel {
    func loadCurrencyList() async {
        guard currencyList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.currencyList.data),
                load(&taskGroup, keyPath: \Self.currencyList.used),
                load(&taskGroup, keyPath: \Self.currencyList.order),
                load(&taskGroup, keyPath: \Self.currencyList.history),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        currencyList.loaded(ok: ok)
    }

    func unloadCurrencyList() {
        guard currencyList.reloading() else { return }
        currencyList.count.unload()
        currencyList.data.unload()
        currencyList.name.unload()
        currencyList.used.unload()
        currencyList.order.unload()
        currencyList.info.unload()
        currencyList.history.unload()
        currencyList.unloaded()
    }
}
