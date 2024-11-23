//
//  PayeeList.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct PayeeList: ListProtocol {
    typealias MainRepository = PayeeRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var att   : LoadAuxAtt<MainRepository>    = .init()
}

extension ViewModel {
    func loadPayeeList(_ pref: Preference) async {
        guard payeeList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.payeeList.data),
                load(&taskGroup, keyPath: \Self.payeeList.used),
                load(&taskGroup, keyPath: \Self.payeeList.order),
                load(&taskGroup, keyPath: \Self.payeeList.att),
                // auxiliary
                //load(&taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
                load(&taskGroup, keyPath: \Self.categoryList.data),
                load(&taskGroup, keyPath: \Self.categoryList.order),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalPath),
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalTree),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        } }
        payeeList.loaded(ok: ok)
    }

    func unloadPayeeList() {
        guard payeeList.reloading() else { return }
        payeeList.count.unload()
        payeeList.data.unload()
        payeeList.used.unload()
        payeeList.order.unload()
        payeeList.att.unload()
        payeeList.unloaded()
    }
}
