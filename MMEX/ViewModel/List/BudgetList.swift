//
//  BudgetList.swift
//  MMEX
//
//  2024-11-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct BudgetList: ListProtocol {
    typealias MainRepository = BudgetRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()  // always empty
    var order : LoadMainOrder<MainRepository> = .init(order: [
        MainRepository.col_yearId,
        MainRepository.col_categId
    ])
}

extension ViewModel {
    func loadBudgetList() async {
        guard budgetList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.budgetList.data),
                load(&taskGroup, keyPath: \Self.budgetList.used),
                load(&taskGroup, keyPath: \Self.budgetList.order),
                // auxiliary
                load(&taskGroup, keyPath: \Self.budgetPeriodList.data),
                load(&taskGroup, keyPath: \Self.budgetPeriodList.order),
                load(&taskGroup, keyPath: \Self.categoryList.data),
                load(&taskGroup, keyPath: \Self.categoryList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.categoryList.evalPath),
                load(&taskGroup, keyPath: \Self.categoryList.evalTree),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        } }
        budgetList.loaded(ok: ok)
    }

    func unloadBudgetList() {
        guard budgetList.reloading() else { return }
        budgetList.count.unload()
        budgetList.data.unload()
        budgetList.used.unload()
        budgetList.order.unload()
        budgetList.unloaded()
    }
}
