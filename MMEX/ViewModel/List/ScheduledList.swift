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
    
    typealias QP = ScheduledSplitRepository
    var split: LoadAuxData<MainRepository, QP> = .init(
        mainId   : { DataId($0[QP.col_transId]) },
        auxTable : QP.table.order(QP.col_id)
    )
    var splitTagLink: LoadAuxTagLink<QP> = .init()
}

extension ScheduledList {
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
        unloaded()
    }
}

extension ViewModel {
    func loadScheduledList(_ pref: Preference) async {
        guard scheduledList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.scheduledList.data),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.used),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.order),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.tagLink),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.fieldValue),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.attachment),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.split),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.splitTagLink),
                // auxiliary
                load(pref, &taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(pref, &taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
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
        scheduledList.loaded(ok: ok)
    }
}
