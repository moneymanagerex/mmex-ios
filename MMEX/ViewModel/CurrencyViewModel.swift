//
//  CurrencyViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

enum CurrencyGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct CurrencyGroup: RepositoryGroupProtocol {
    typealias MainRepository = CurrencyRepository
    typealias GroupChoice    = CurrencyGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState = .init()
    var value: ValueType = []
}

struct CurrencySearch: RepositorySearchProtocol {
    var area: [RepositorySearchArea<CurrencyData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}

extension RepositoryViewModel {
    func loadCurrencyList() async {
        guard currencyList.state.loading() else { return }
        log.trace("DEBUG: RepositoryViewModel.loadCurrencyList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyData)
            load(queue: &queue, keyPath: \Self.currencyOrder)
            load(queue: &queue, keyPath: \Self.currencyUsed)
            return await allOk(queue: queue)
        }
        currencyList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadCurrencyList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadCurrencyList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadCurrencyList() {
        guard currencyList.state.unloading() else { return }
        log.trace("DEBUG: RepositoryViewModel.unloadCurrencyList(main=\(Thread.isMainThread))")
        currencyData.unload()
        currencyOrder.unload()
        currencyUsed.unload()
        currencyList.state.unloaded()
    }
}

extension RepositoryViewModel {
    func loadCurrencyGroup(choice: CurrencyGroupChoice) {
        // TODO
    }

    func unloadCurrencyGroup() {
        currencyGroup.unload()
    }
}

extension RepositoryViewModel {
    func reloadCurrencyList(_ oldData: CurrencyData?, _ newData: CurrencyData?) async {
    }
}

extension RepositoryViewModel {
    func currencyGroupIsVisible(_ g: Int, search: CurrencySearch
    ) -> Bool? {
        guard
            currencyData.state  == .ready,
            currencyGroup.state == .ready
        else { return nil }

        let dataDict  = currencyData.value
        let groupData = currencyGroup.value

        if search.isEmpty {
            return switch currencyGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(dataDict[$0]!) }) != nil
    }

    func searchCurrencyGroup(search: CurrencySearch, expand: Bool = false ) {
        guard currencyGroup.state == .ready else { return }
        for g in 0 ..< currencyGroup.value.count {
            guard let isVisible = currencyGroupIsVisible(g, search: search) else { return }
            currencyGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                currencyGroup.value[g].isExpanded = true
            }
        }
    }
}
