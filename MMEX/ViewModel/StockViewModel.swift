//
//  StockViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum StockGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct StockGroup: RepositoryLoadGroupProtocol {
    typealias GroupChoice    = StockGroupChoice
    typealias MainRepository = StockRepository
    
    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[RepositoryGroupData]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []
}

extension RepositoryViewModel {
    func loadStockList() async {
        log.trace("DEBUG: RepositoryViewModel.loadStockList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.stockData)
            load(queue: &queue, keyPath: \Self.stockOrder)
            load(queue: &queue, keyPath: \Self.stockUsed)
            return await allOk(queue: queue)
        }
        stockList.state = queueOk ? .ready(()) : .error("Cannot load data.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadStockList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadStockList(main=\(Thread.isMainThread)): Cannot load data.")
            return
        }
    }

    func unloadStockList() {
        log.trace("DEBUG: RepositoryViewModel.unloadStockList(main=\(Thread.isMainThread))")
        stockData.unload()
        stockOrder.unload()
        stockUsed.unload()
        stockList.state = .idle
    }
}

extension RepositoryViewModel {
    func unloadStockGroup() -> Bool? {
        log.trace("DEBUG: RepositoryViewModel.unloadStockGroup(main=\(Thread.isMainThread))")
        if case .loading = stockGroup.state { return nil }
        stockGroup.state = .idle
        stockGroup.isVisible  = []
        stockGroup.isExpanded = []
        return true
    }
}
