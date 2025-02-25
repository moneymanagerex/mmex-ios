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

extension CurrencyList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        name.unload()
        used.unload()
        order.unload()
        info.unload()
        history.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadCurrencyList(_ pref: Preference) async {
        guard currencyList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(pref, &taskGroup, keyPath: \Self.currencyList.name),
                load(pref, &taskGroup, keyPath: \Self.currencyList.data),
                load(pref, &taskGroup, keyPath: \Self.currencyList.used),
                load(pref, &taskGroup, keyPath: \Self.currencyList.order),
                load(pref, &taskGroup, keyPath: \Self.currencyList.history),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        currencyList.loaded(ok: ok)
    }
}
