//
//  CurrencyViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum CurrencyGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct CurrencyGroup: RepositoryLoadGroupProtocol {
    typealias GroupChoice    = CurrencyGroupChoice
    typealias RepositoryType = CurrencyRepository
    
    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[[DataId]]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []
}

extension RepositoryViewModel {
    func loadCurrencyData() async {
        log.trace("DEBUG: RepositoryViewModel.loadCurrencyData(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.currencyDict)
            load(queue: &queue, keyPath: \Self.currencyOrder)
            load(queue: &queue, keyPath: \Self.currencyUsed)
            return await allOk(queue: queue)
        }
        currencyData.state = queueOk ? .ready(()) : .error("Cannot load data.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadCurrencyData(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadCurrencyData(main=\(Thread.isMainThread)): Cannot load data.")
            return
        }
    }

    func unloadCurrencyData() {
        log.trace("DEBUG: RepositoryViewModel.unloadCurrencyData(main=\(Thread.isMainThread))")
        currencyDict.unload()
        currencyOrder.unload()
        currencyUsed.unload()
        currencyData.state = .idle
    }
}
