//
//  ScheduledList.swift
//  MMEX
//
//  2024-11-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct ScheduledList: ListProtocol {
    typealias MainRepository = ScheduledRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
}

extension ViewModel {
    func loadScheduledList() async {
        guard scheduledList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.scheduledList.data),
                load(&taskGroup, keyPath: \Self.scheduledList.used),
                // auxiliary
                load(&taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(&taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                load(&taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
                load(&taskGroup, keyPath: \Self.currencyList.info),
                load(&taskGroup, keyPath: \Self.accountList.data),
                load(&taskGroup, keyPath: \Self.accountList.order),
                load(&taskGroup, keyPath: \Self.categoryList.data),
                load(&taskGroup, keyPath: \Self.categoryList.order),
                load(&taskGroup, keyPath: \Self.payeeList.data),
                load(&taskGroup, keyPath: \Self.payeeList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.categoryList.path),
                load(&taskGroup, keyPath: \Self.categoryList.tree),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        } }
        scheduledList.loaded(ok: ok)
    }

    func unloadScheduledList() {
        guard scheduledList.unloading() else { return }
        scheduledList.data.unload()
        scheduledList.used.unload()
        scheduledList.unloaded()
    }
}
