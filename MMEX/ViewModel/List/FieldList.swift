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
        MainRepository.col_refType, MainRepository.col_description
    ])
}

extension ViewModel {
    func loadFieldList() async {
        guard fieldList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.fieldList.data),
                load(&taskGroup, keyPath: \Self.fieldList.used),
                load(&taskGroup, keyPath: \Self.fieldList.order)
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        fieldList.loaded(ok: ok)
    }

    func unloadFieldList() {
        guard fieldList.unloading() else { return }
        fieldList.data.unload()
        fieldList.used.unload()
        fieldList.order.unload()
        fieldList.unloaded()
    }
}
