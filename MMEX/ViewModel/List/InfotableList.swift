//
//  InfotableList.swift
//  MMEX
//
//  2024-11-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct LoadInfotableValue<MainValue>: LoadFetchProtocol {
    typealias MainRepository = InfotableRepository
    typealias ValueType = MainValue?
    let loadName: String = "Value(\(MainRepository.repositoryName))"
    let idleValue: ValueType = nil

    let key: String
    let table: SQLite.Table = MainRepository.table
    var state: LoadState = .init()
    var value: ValueType = nil

    init(key: String) {
        self.key = key
        self.value = idleValue
    }

    nonisolated func fetchValue(env: EnvironmentManager) async -> ValueType? {
        MainRepository(env)?.getValue(for: key, as: MainValue.self)
    }
}

struct InfotableList: ListProtocol {
    typealias MainRepository = InfotableRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var name  : LoadMainName<MainRepository>  = .init { $0[MainRepository.col_name] }
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var used  : LoadMainUsed<MainRepository>  = .init()

    var baseCurrencyId    : LoadInfotableValue<DataId> = .init(key: InfoKey.baseCurrencyID.rawValue)
    var defaultAccountId  : LoadInfotableValue<DataId> = .init(key: InfoKey.defaultAccountID.rawValue)
    var categoryDelimiter : LoadInfotableValue<String> = .init(key: InfoKey.categDelimiter.rawValue)
}

extension ViewModel {
    func loadInfotableList() async {
        guard infotableList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.infotableList.data),
                load(&taskGroup, keyPath: \Self.infotableList.order),
                //load(&taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                //load(&taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                //load(&taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        infotableList.loaded(ok: ok)
    }

    func unloadInfotableList() {
        guard infotableList.unloading() else { return }
        infotableList.data.unload()
        infotableList.order.unload()
        infotableList.unloaded()
    }
}
