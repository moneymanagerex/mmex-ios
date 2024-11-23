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

extension ViewModel {
    func loadBudgetPeriodList(_ pref: Preference) async {
        guard budgetPeriodList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.budgetPeriodList.data),
                load(&taskGroup, keyPath: \Self.budgetPeriodList.used),
                load(&taskGroup, keyPath: \Self.budgetPeriodList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        budgetPeriodList.loaded(ok: ok)
    }

    func unloadBudgetPeriodList() {
        guard budgetPeriodList.reloading() else { return }
        budgetPeriodList.count.unload()
        budgetPeriodList.data.unload()
        budgetPeriodList.used.unload()
        budgetPeriodList.order.unload()
        budgetPeriodList.unloaded()
    }
}
