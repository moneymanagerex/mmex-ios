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
        MainRepository.col_id
    ])

    var evalOrder : LoadBudgetOrder = .init()
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
                load(&taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
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
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.budgetList.evalOrder),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        } }
        budgetList.loaded(ok: ok)
    }

    func unloadBudgetList() {
        guard budgetList.reloading() else { return }
        budgetList.evalOrder.unload()
        budgetList.count.unload()
        budgetList.data.unload()
        budgetList.used.unload()
        budgetList.order.unload()
        budgetList.unloaded()
    }
}

struct LoadBudgetOrder: LoadEvalProtocol {
    typealias ValueType = [DataId]
    let loadName: String = "EvalOrder(\(BudgetRepository.repositoryName))"
    let idleValue: ValueType = []

    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(env: EnvironmentManager, vm: ViewModel) async -> ValueType? {
        return await vm.evalBudgetOrder()
    }
}

extension ViewModel {
    nonisolated func evalBudgetOrder() async -> [DataId]? {
        guard
            let budgetData    = await budgetList.data.readyValue,
            let budgetOrder   = await budgetList.order.readyValue,
            let periodOrder   = await budgetPeriodList.order.readyValue,
            let categoryIndex = await categoryList.evalTree.readyValue?.indexById
        else { return nil }

        let periodIndex = Dictionary(
            uniqueKeysWithValues: periodOrder.enumerated().map { ($0.1, $0.0) }
        )
        return budgetOrder.sorted {
            let p0 = periodIndex[budgetData[$0]!.periodId] ?? -1
            let p1 = periodIndex[budgetData[$1]!.periodId] ?? -1
            let c0 = categoryIndex[budgetData[$0]!.categoryId] ?? -1
            let c1 = categoryIndex[budgetData[$1]!.categoryId] ?? -1
            return (p0 < p1) || (p0 == p1 && c0 < c1)
        }
    }
}
