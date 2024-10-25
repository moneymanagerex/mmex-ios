//
//  StockViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

enum StockGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct StockGroup: RepositoryGroupProtocol {
    typealias MainRepository = StockRepository
    typealias GroupChoice    = StockGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState = .init()
    var value: ValueType = []
}

struct StockSearch: RepositorySearchProtocol {
    var area: [RepositorySearchArea<StockData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}

extension RepositoryViewModel {
    func loadStockList() async {
        guard stockList.state.loading() else { return }
        log.trace("DEBUG: RepositoryViewModel.loadStockList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.stockData)
            load(queue: &queue, keyPath: \Self.stockOrder)
            load(queue: &queue, keyPath: \Self.stockUsed)
            return await allOk(queue: queue)
        }
        stockList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadStockList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadStockList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadStockList() {
        guard stockList.state.unloading() else { return }
        log.trace("DEBUG: RepositoryViewModel.unloadStockList(main=\(Thread.isMainThread))")
        stockData.unload()
        stockOrder.unload()
        stockUsed.unload()
        stockList.state.unloaded()
    }
}

extension RepositoryViewModel {
    func loadStockGroup(choice: StockGroupChoice) {
    }

    func unloadStockGroup() {
        stockGroup.unload()
    }
}

extension RepositoryViewModel {
    func reloadStockList(_ oldData: StockData?, _ newData: StockData?) async {
    }
}

extension RepositoryViewModel {
    func stockGroupIsVisible(_ g: Int, search: StockSearch
    ) -> Bool? {
        guard
            stockData.state  == .ready,
            stockGroup.state == .ready
        else { return nil }

        let dataDict  = stockData.value
        let groupData = stockGroup.value

        if search.isEmpty {
            return switch stockGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(dataDict[$0]!) }) != nil
    }

    func searchStockGroup(search: StockSearch, expand: Bool = false ) {
        guard stockGroup.state == .ready else { return }
        for g in 0 ..< stockGroup.value.count {
            guard let isVisible = stockGroupIsVisible(g, search: search) else { return }
            stockGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                stockGroup.value[g].isExpanded = true
            }
        }
    }
}
