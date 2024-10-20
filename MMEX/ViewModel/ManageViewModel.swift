//
//  ManageViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension RepositoryViewModel {
    func loadManage() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyDataCount)
            load(queue: &queue, keyPath: \Self.accountDataCount)
            load(queue: &queue, keyPath: \Self.assetDataCount)
            load(queue: &queue, keyPath: \Self.stockDataCount)
            load(queue: &queue, keyPath: \Self.categoryDataCount)
            load(queue: &queue, keyPath: \Self.payeeDataCount)
            load(queue: &queue, keyPath: \Self.transactionDataCount)
            load(queue: &queue, keyPath: \Self.scheduledDataCount)
            return await allOk(queue: queue)
        }
        manageCount = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadManege() {
        currencyDataCount.unload()
        accountDataCount.unload()
        assetDataCount.unload()
        stockDataCount.unload()
        categoryDataCount.unload()
        payeeDataCount.unload()
        transactionDataCount.unload()
        scheduledDataCount.unload()
    }
}
