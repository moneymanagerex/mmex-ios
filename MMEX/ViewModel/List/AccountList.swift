//
//  AccountList.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct AccountList: ListProtocol {
    typealias MainRepository = AccountRepository

    var state : LoadState                         = .init()
    var count : LoadMainCount<MainRepository>     = .init()
    var data  : LoadMainData<MainRepository>      = .init()
    var used  : LoadMainUsed<MainRepository>      = .init()
    var order : LoadMainOrder<MainRepository>     = .init(order: [MainRepository.col_name])

    var attachment : LoadAuxAttachment<MainRepository> = .init()
}

extension AccountList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        attachment.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadAccountList(_ pref: Preference) async {
        guard accountList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.used),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
                load(pref, &taskGroup, keyPath: \Self.accountList.attachment),
                // auxiliary
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.currencyList.name),
                load(pref, &taskGroup, keyPath: \Self.currencyList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        accountList.loaded(ok: ok)
    }
}
