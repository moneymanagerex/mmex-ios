//
//  ManageList.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    /*
    func initManageList() {
        for publisher in [
            $currencyList.map(\.count.state).eraseToAnyPublisher(),
            $accountList.map(\.count.state).eraseToAnyPublisher(),
            $assetList.map(\.count.state).eraseToAnyPublisher(),
            $stockList.map(\.count.state).eraseToAnyPublisher(),
            $categoryList.map(\.count.state).eraseToAnyPublisher(),
            $payeeList.map(\.count.state).eraseToAnyPublisher(),
            //$transactionList.map(\.count.state),
            //$scheduledList.map(\.count.state),
        ] {
            publisher
                .sink { [weak self] (state: LoadState) in
                    guard let self else { return }
                    if state == .idle {
                        self.manageList.unload()
                    }
                }
                .store(in: &self.subscriptions)
        }
    }
    */

    func loadManageList() async {
        guard manageList.reloading() else { return }
        log.trace("DEBUG: ViewModel.loadManageList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.infotableList.count),
                load(&taskGroup, keyPath: \Self.currencyList.count),
                load(&taskGroup, keyPath: \Self.accountList.count),
                load(&taskGroup, keyPath: \Self.assetList.count),
                load(&taskGroup, keyPath: \Self.stockList.count),
                load(&taskGroup, keyPath: \Self.categoryList.count),
                load(&taskGroup, keyPath: \Self.payeeList.count),
                load(&taskGroup, keyPath: \Self.transactionList.count),
                load(&taskGroup, keyPath: \Self.scheduledList.count),
                load(&taskGroup, keyPath: \Self.tagList.count),
            ].allSatisfy { $0 }
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

    func unloadManegeList() {
        guard manageList.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadManageList(main=\(Thread.isMainThread))")
        infotableList.count.unload()
        currencyList.count.unload()
        accountList.count.unload()
        assetList.count.unload()
        stockList.count.unload()
        categoryList.count.unload()
        payeeList.count.unload()
        transactionList.count.unload()
        scheduledList.count.unload()
        tagList.count.unload()
        manageList.unloaded()
    }
}
