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

extension TransactionList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadTransactionList(_ pref: Preference) async {
        guard transactionList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.transactionList.data),
                load(pref, &taskGroup, keyPath: \Self.transactionList.used),
                // auxiliary
                load(pref, &taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(pref, &taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                //load(pref, &taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
                load(pref, &taskGroup, keyPath: \Self.categoryList.data),
                load(pref, &taskGroup, keyPath: \Self.categoryList.order),
                load(pref, &taskGroup, keyPath: \Self.payeeList.data),
                load(pref, &taskGroup, keyPath: \Self.payeeList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalPath),
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalTree),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        } }
        transactionList.loaded(ok: ok)
    }
}
