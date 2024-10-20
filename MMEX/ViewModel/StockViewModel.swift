//
//  StockViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension RepositoryViewModel {
    func loadStockList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.stockDict)
            load(queue: &queue, keyPath: \Self.stockOrder)
            load(queue: &queue, keyPath: \Self.stockUsed)
            return await allOk(queue: queue)
        }
        stockList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadStockList() {
        stockDict.unload()
        stockOrder.unload()
        stockUsed.unload()
        stockList.state = .idle
    }
}
