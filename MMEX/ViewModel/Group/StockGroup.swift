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
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.stock"
    }

    static let groupUsed : [Bool] = [true, false]
    static let groupAtt  : [Bool] = [true, false]

    var groupAccount: [DataId] = []
}

extension ViewModel {
    func loadStockGroup(choice: StockGroupChoice) {
        guard
            let listData     = stockList.data.readyValue,
            let listUsed     = stockList.used.readyValue,
            let listOrder    = stockList.order.readyValue,
            let listAtt      = stockList.attachment.readyValue,
            let accountData  = accountList.data.readyValue,
            let accountOrder = accountList.order.readyValue
        else { return }

        guard stockGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadStockGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        stockGroup.choice = choice
        stockGroup.search = false
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
            stockGroup.groupAccount = accountOrder.compactMap {
                dict[$0] != nil ? $0 : nil
            }
            for g in stockGroup.groupAccount {
                let name = accountData[g]?.name
                stockGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in StockGroup.groupAtt {
                let name = g ? "With Attachment" : "Other"
                stockGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        stockGroup.state.loaded()
        log.info("INFO: ViewModel.loadStockGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
