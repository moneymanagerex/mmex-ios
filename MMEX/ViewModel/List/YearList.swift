//
//  YearList.swift
//  MMEX
//
//  2024-11-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct YearList: ListProtocol {
    typealias MainRepository = YearRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
}

extension ViewModel {
    func loadYearList() async {
        guard yearList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.yearList.data),
                load(&taskGroup, keyPath: \Self.yearList.used),
                load(&taskGroup, keyPath: \Self.yearList.order)
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        yearList.loaded(ok: ok)
    }

    func unloadYearList() {
        guard yearList.reloading() else { return }
        yearList.count.unload()
        yearList.data.unload()
        yearList.used.unload()
        yearList.order.unload()
        yearList.unloaded()
    }
}
