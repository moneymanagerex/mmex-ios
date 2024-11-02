//
//  PayeeGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum PayeeGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case active     = "Active"
    case category   = "Category"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct PayeeGroup: GroupProtocol {
    typealias MainRepository = PayeeRepository
    typealias GroupChoice    = PayeeGroupChoice
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

    static let groupActive: [Bool] = [
        true, false
    ]

    var groupCategory: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

extension ViewModel {
    func loadPayeeGroup(choice: PayeeGroupChoice) {
        guard
            let listData     = payeeList.data.readyValue,
            let listUsed     = payeeList.used.readyValue,
            let listOrder    = payeeList.order.readyValue,
            let listAtt      = payeeList.att.readyValue,
            let categoryPath = categoryList.path.readyValue
        else { return }

        guard payeeGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadPayeeGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        payeeGroup.choice = choice
        payeeGroup.groupCategory = []

        switch choice {
        case .all:
            payeeGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in PayeeGroup.groupUsed {
                let name = g ? "Used" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        case .active:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.active }
            for g in PayeeGroup.groupActive {
                let name = g ? "Active" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        case .category:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.categoryId }
            payeeGroup.groupCategory = categoryPath.path.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in payeeGroup.groupCategory {
                var name = categoryPath.path[g]
                if name != nil, name!.isEmpty { name = "(none)" }
                payeeGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in PayeeGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                payeeGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        payeeGroup.state.loaded()
        log.info("INFO: ViewModel.loadPayeeGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }

    func unloadPayeeGroup() {
        payeeGroup.unload()
    }
}
