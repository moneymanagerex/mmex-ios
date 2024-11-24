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

    nonisolated func fetchValue(pref: Preference, vm: ViewModel) async -> ValueType? {
        await InfotableRepository(vm)?.getValue(for: key, default: idleValue)
    }
}

struct InfotableList: ListProtocol {
    typealias MainRepository = InfotableRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])

    var baseCurrencyId    : LoadInfotableValue<DataId> = .init(
        key: InfoKey.baseCurrencyID.rawValue,
        default: DataId.void
    )
    var defaultAccountId  : LoadInfotableValue<DataId> = .init(
        key: InfoKey.defaultAccountID.rawValue,
        default: DataId.void
    )
    /*
    var categoryDelimiter : LoadInfotableValue<String> = .init(
        key: InfoKey.categDelimiter.rawValue,
        default: ":"
    )
     */
}

extension InfotableList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        baseCurrencyId.unload()
        defaultAccountId.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadInfotableList(_ pref: Preference) async {
        guard infotableList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.infotableList.data),
                load(pref, &taskGroup, keyPath: \Self.infotableList.order),
                //load(pref, &taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                //load(pref, &taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                //load(pref, &taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        infotableList.loaded(ok: ok)
    }
}
