//
//  CurrencyViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension RepositoryViewModel {
    func loadCurrencyList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyDict)
            load(queue: &queue, keyPath: \Self.currencyOrder)
            load(queue: &queue, keyPath: \Self.currencyUsed)
            return await allOk(queue: queue)
        }
        currencyList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadCurrencyList() {
        currencyDict.unload()
        currencyOrder.unload()
        currencyUsed.unload()
        currencyList.state = .idle
    }
}
