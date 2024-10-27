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
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.currencyList.count),
                load(&taskGroup, keyPath: \Self.accountList.count),
                load(&taskGroup, keyPath: \Self.assetList.count),
                load(&taskGroup, keyPath: \Self.stockList.count),
                load(&taskGroup, keyPath: \Self.categoryList.count),
                load(&taskGroup, keyPath: \Self.payeeList.count),
                load(&taskGroup, keyPath: \Self.transactionCount),
                load(&taskGroup, keyPath: \Self.scheduledCount),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        manageList.loaded(ok: ok)
        if ok {
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
