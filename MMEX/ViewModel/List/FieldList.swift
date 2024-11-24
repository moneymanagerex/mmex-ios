//
//  FieldList.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct FieldList: ListProtocol {
    typealias MainRepository = FieldRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [
        MainRepository.col_description,
        MainRepository.col_refType
    ])
}

extension ViewModel {
    func loadFieldList(_ pref: Preference) async {
        guard fieldList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.fieldList.data),
                load(pref, &taskGroup, keyPath: \Self.fieldList.used),
                load(pref, &taskGroup, keyPath: \Self.fieldList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        fieldList.loaded(ok: ok)
    }

    func unloadFieldList() {
        guard fieldList.reloading() else { return }
        fieldList.count.unload()
        fieldList.data.unload()
        fieldList.used.unload()
        fieldList.order.unload()
        fieldList.unloaded()
    }
}
