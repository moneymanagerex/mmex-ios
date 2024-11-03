//
//  TransactionList.swift
//  MMEX
//
//  2024-11-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct TransactionList: ListProtocol {
    typealias MainRepository = TransactionRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
}

extension ViewModel {
    func loadTransactionList() async {
        guard transactionList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.transactionList.data),
                load(&taskGroup, keyPath: \Self.transactionList.used),
                // auxiliary
                load(&taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
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
        transactionList.loaded(ok: ok)
    }

    func unloadTransactionList() {
        guard transactionList.unloading() else { return }
        transactionList.data.unload()
        transactionList.used.unload()
        transactionList.unloaded()
    }
}
