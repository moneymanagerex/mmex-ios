//
//  ManageViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension RepositoryViewModel {
    func loadManage() async {
        log.trace("DEBUG: RepositoryViewModel.loadManage(main=\(Thread.isMainThread))")
        guard case .idle = manageCount else { return }
        manageCount = .loading
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyCount)
            load(queue: &queue, keyPath: \Self.accountCount)
            load(queue: &queue, keyPath: \Self.assetCount)
            load(queue: &queue, keyPath: \Self.stockCount)
            load(queue: &queue, keyPath: \Self.categoryCount)
            load(queue: &queue, keyPath: \Self.payeeCount)
            load(queue: &queue, keyPath: \Self.transactionCount)
            load(queue: &queue, keyPath: \Self.scheduledCount)
            return await allOk(queue: queue)
        }
        manageCount = queueOk ? .ready(()) : .error("Cannot load.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadManage(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadManage(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadManege() {
        log.trace("DEBUG: RepositoryViewModel.unloadManage(main=\(Thread.isMainThread))")
        if case .loading = manageCount { return }
        manageCount = .loading
        currencyCount.unload()
        accountCount.unload()
        assetCount.unload()
        stockCount.unload()
        categoryCount.unload()
        payeeCount.unload()
        transactionCount.unload()
        scheduledCount.unload()
        manageCount = .idle
    }
}
