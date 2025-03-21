//
//  AssetGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AssetGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case status     = "Status"
    case type       = "Type"
    case currency   = "Currency"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AssetGroup: GroupProtocol {
    typealias MainRepository = AssetRepository
    typealias GroupChoice    = AssetGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.asset"
    }

    static let groupUsed   : [Bool] = [true, false]
    static let groupStatus : [AssetStatus] = [.open, .closed]
    static let groupType   : [AssetType] = [
        .property, .automobile, .household, .art, .jewellery, .cash, .other
    ]
    static let groupAtt    : [Bool] = [true, false]

    var groupCurrency: [DataId] = []
}

extension ViewModel {
    func loadAssetGroup(choice: AssetGroupChoice) {
        guard
            let listData      = assetList.data.readyValue,
            let listUsed      = assetList.used.readyValue,
            let listOrder     = assetList.order.readyValue,
            let listAtt       = assetList.attachment.readyValue,
            let currencyName  = currencyList.name.readyValue,
            let currencyOrder = currencyList.order.readyValue
        else { return }

        guard assetGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAssetGroup(\(choice.rawValue), main=\(Thread.isMainThread))")

        assetGroup.choice = choice
        assetGroup.search = false
        assetGroup.groupCurrency = []

        switch choice {
        case .all:
            assetGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in AssetGroup.groupUsed {
                let name = g ? "Used" : "Other"
                assetGroup.append(name, dict[g] ?? [], true, true)
            }
        case .status:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.status }
            for g in AssetGroup.groupStatus {
                assetGroup.append(g.rawValue, dict[g] ?? [], true, true)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in AssetGroup.groupType {
                assetGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.currencyId }
            assetGroup.groupCurrency = currencyOrder.compactMap {
                dict[$0] != nil ? $0 : nil
            }
            for g in assetGroup.groupCurrency {
                let name = currencyName[g]
                assetGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in AssetGroup.groupAtt {
                let name = g ? "With Attachment" : "Other"
                assetGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        assetGroup.state.loaded()
        log.info("INFO: ViewModel.loadAssetGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
