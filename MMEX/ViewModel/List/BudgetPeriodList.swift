//
//  BudgetPeriodList.swift
//  MMEX
//
//  2024-11-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct BudgetPeriodList: ListProtocol {
    typealias MainRepository = BudgetPeriodRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
}

extension BudgetPeriodList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadBudgetPeriodList(_ pref: Preference) async {
        guard budgetPeriodList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.budgetPeriodList.data),
                load(pref, &taskGroup, keyPath: \Self.budgetPeriodList.used),
                load(pref, &taskGroup, keyPath: \Self.budgetPeriodList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        budgetPeriodList.loaded(ok: ok)
    }
}
