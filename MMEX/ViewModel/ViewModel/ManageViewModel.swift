//
//  ManageViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadManage() async {
        guard manageList.loading() else { return }
        log.trace("DEBUG: ViewModel.loadManage(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyList.count)
            load(queue: &queue, keyPath: \Self.accountList.count)
            load(queue: &queue, keyPath: \Self.assetList.count)
            load(queue: &queue, keyPath: \Self.stockList.count)
            load(queue: &queue, keyPath: \Self.categoryList.count)
            load(queue: &queue, keyPath: \Self.payeeList.count)
            load(queue: &queue, keyPath: \Self.transactionCount)
            load(queue: &queue, keyPath: \Self.scheduledCount)
            return await allOk(queue: queue)
        }
        manageList.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: ViewModel.loadManage(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadManage(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadManege() {
        guard manageList.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadManage(main=\(Thread.isMainThread))")
        currencyList.count.unload()
        accountList.count.unload()
        assetList.count.unload()
        stockList.count.unload()
        categoryList.count.unload()
        payeeList.count.unload()
        transactionCount.unload()
        scheduledCount.unload()
        manageList.unloaded()
    }
}
