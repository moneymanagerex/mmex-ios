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

    var state : LoadState                         = .init()
    var count : LoadMainCount<MainRepository>     = .init()
    var data  : LoadMainData<MainRepository>      = .init()
    var used  : LoadMainUsed<MainRepository>      = .init()  // always empty
    var order : LoadMainOrder<MainRepository>     = .init(
        order : [MainRepository.col_transDate, MainRepository.col_id]
    )

    var tagLink    : LoadAuxTagLink<MainRepository>    = .init()
    var fieldValue : LoadAuxFieldValue<MainRepository> = .init()
    var attachment : LoadAuxAttachment<MainRepository> = .init()
    
    typealias TP = TransactionSplitRepository
    var split: LoadAuxData<MainRepository, TP> = .init(
        mainId   : { DataId($0[TP.col_transId]) },
        auxTable : TP.table.order(TP.col_id)
    )
    var splitTagLink: LoadAuxTagLink<TP> = .init()

    typealias TL = TransactionLinkRepository
    var transLink : LoadAuxData<MainRepository, TL> = .init(
        mainId   : { DataId($0[TL.col_transId]) },
        auxTable : TL.table.order(TL.col_id)
    )

    typealias TS = TransactionShareRepository
    var share : LoadAuxData<MainRepository, TS> = .init(
        mainId   : { DataId($0[TS.col_transId]) },
        auxTable : TS.table.order(TS.col_id)
    )
}

extension TransactionList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        tagLink.unload()
        fieldValue.unload()
        attachment.unload()
        split.unload()
        splitTagLink.unload()
        transLink.unload()
        share.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadTransactionList(_ pref: Preference) async {
        guard transactionList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                //load(pref, &taskGroup, keyPath: \Self.transactionList.data),
                //load(pref, &taskGroup, keyPath: \Self.transactionList.used),
                // auxiliary
                load(pref, &taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(pref, &taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
                load(pref, &taskGroup, keyPath: \Self.assetList.data),
                load(pref, &taskGroup, keyPath: \Self.assetList.order),
                load(pref, &taskGroup, keyPath: \Self.stockList.data),
                load(pref, &taskGroup, keyPath: \Self.stockList.order),
                load(pref, &taskGroup, keyPath: \Self.categoryList.data),
                load(pref, &taskGroup, keyPath: \Self.categoryList.order),
                load(pref, &taskGroup, keyPath: \Self.payeeList.data),
                load(pref, &taskGroup, keyPath: \Self.payeeList.order),
                load(pref, &taskGroup, keyPath: \Self.tagList.data),
                load(pref, &taskGroup, keyPath: \Self.tagList.order),
                load(pref, &taskGroup, keyPath: \Self.fieldList.data),
                load(pref, &taskGroup, keyPath: \Self.fieldList.order),
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
