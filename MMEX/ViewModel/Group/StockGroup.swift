//
//  StockGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum StockGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case account    = "Account"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct StockGroup: GroupProtocol {
    typealias MainRepository = StockRepository
    typealias GroupChoice    = StockGroupChoice
    let idleValue: ValueType = []

    var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
    }

    static let groupUsed: [Bool] = [
        true, false
    ]

    var groupAccount: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

extension ViewModel {
    func loadStockGroup(choice: StockGroupChoice) {
        guard
            let listData    = stockList.data.readyValue,
            let listUsed    = stockList.used.readyValue,
            let listOrder   = stockList.order.readyValue,
            let listAtt     = stockList.att.readyValue,
            let accountData = accountList.data.readyValue
        else { return }

        guard stockGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadStockGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        stockGroup.choice = choice
        stockGroup.groupAccount = []

        switch choice {
        case .all:
            stockGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in StockGroup.groupUsed {
                let name = g ? "Used" : "Other"
                stockGroup.append(name, dict[g] ?? [], true, g)
            }
        case .account:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.accountId }
            stockGroup.groupAccount = accountData.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value.name) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in stockGroup.groupAccount {
                let name = accountData[g]?.name
                stockGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in StockGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                stockGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        stockGroup.state.loaded()
        log.info("INFO: ViewModel.loadStockGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }

    func unloadStockGroup() {
        stockGroup.unload()
    }
}
