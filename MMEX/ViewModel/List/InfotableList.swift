//
//  InfotableList.swift
//  MMEX
//
//  2024-11-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct LoadInfotableValue<MainValue: LosslessStringConvertible>: LoadFetchProtocol {
    typealias MainRepository = InfotableRepository
    typealias ValueType = MainValue
    let loadName: String = "Value(\(MainRepository.repositoryName))"
    let idleValue: ValueType

    let key: String
    var state: LoadState = .init()
    var value: ValueType

    init(key: String, default idleValue: ValueType) {
        self.key = key
        self.idleValue = idleValue
        self.value = idleValue
    }

    nonisolated func fetchValue(env: EnvironmentManager) async -> ValueType? {
        InfotableRepository(env)?.getValue(for: key, default: idleValue)
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

    var baseCurrencyId    : LoadInfotableValue<DataId> = .init(
        key: InfoKey.baseCurrencyID.rawValue,
        default: DataId.void
    )
    var defaultAccountId  : LoadInfotableValue<DataId> = .init(
        key: InfoKey.defaultAccountID.rawValue,
        default: DataId.void
    )
    var categoryDelimiter : LoadInfotableValue<String> = .init(
        key: InfoKey.categDelimiter.rawValue,
        default: ":"
    )
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
