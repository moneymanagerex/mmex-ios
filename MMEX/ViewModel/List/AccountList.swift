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

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var name  : LoadMainName<MainRepository>  = .init { $0[MainRepository.col_name] }
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var att   : LoadAuxAtt<MainRepository>    = .init()
}

extension ViewModel {
    func loadAccountList() async {
        guard accountList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.accountList.data),
                load(&taskGroup, keyPath: \Self.accountList.used),
                load(&taskGroup, keyPath: \Self.accountList.order),
                load(&taskGroup, keyPath: \Self.accountList.att),
                // used in EditView
                load(&taskGroup, keyPath: \Self.currencyList.info),
                load(&taskGroup, keyPath: \Self.currencyList.name),
                load(&taskGroup, keyPath: \Self.currencyList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        accountList.loaded(ok: ok)
    }

    func unloadAccountList() {
        guard accountList.unloading() else { return }
        accountList.data.unload()
        accountList.used.unload()
        accountList.order.unload()
        accountList.att.unload()
        accountList.unloaded()
    }
}
