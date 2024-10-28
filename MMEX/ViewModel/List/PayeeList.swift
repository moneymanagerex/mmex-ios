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
    var name  : LoadMainName<MainRepository>  = .init { $0[MainRepository.col_name] }
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var att   : LoadAuxAtt<MainRepository>    = .init()
}

extension ViewModel {
    func loadPayeeList() async {
        guard payeeList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadPayeeList(main=\(Thread.isMainThread))")
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.payeeList.data),
                load(&taskGroup, keyPath: \Self.payeeList.used),
                load(&taskGroup, keyPath: \Self.payeeList.order),
                load(&taskGroup, keyPath: \Self.payeeList.att),
                // used in EditView
                load(&taskGroup, keyPath: \Self.categoryList.data),
                load(&taskGroup, keyPath: \Self.categoryList.order),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.categoryList.path),
                load(&taskGroup, keyPath: \Self.categoryList.tree),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        } }
        payeeList.state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.loadPayeeList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadPayeeList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadPayeeList() {
        guard payeeList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadPayeeList(main=\(Thread.isMainThread))")
        payeeList.data.unload()
        payeeList.used.unload()
        payeeList.order.unload()
        payeeList.att.unload()
        payeeList.state.loaded()
    }
}
