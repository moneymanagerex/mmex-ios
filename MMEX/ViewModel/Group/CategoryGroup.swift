//
//  CategoryGroup.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum CategoryGroupChoice: String, GroupChoiceProtocol {
    case all    = "All"
    case used   = "Used"
    case active = "Active"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct CategoryGroup: GroupProtocol {
    typealias MainRepository = CategoryRepository
    typealias GroupChoice    = CategoryGroupChoice
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
}

extension ViewModel {
    func loadCategoryGroup(choice: CategoryGroupChoice) {
        guard
            let listData  = categoryList.data.readyValue,
            let listUsed  = categoryList.used.readyValue,
            let listOrder = categoryList.order.readyValue
        else { return }

        guard categoryGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCategoryGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        categoryGroup.choice = choice

        switch choice {
        case .all:
            categoryGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in CategoryGroup.groupUsed {
                let name = g ? "Used" : "Other"
                categoryGroup.append(name, dict[g] ?? [], true, g)
            }
        case .active:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.active }
            for g in CategoryGroup.groupActive {
                let name = g ? "Active" : "Other"
                categoryGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        categoryGroup.state.loaded()
        log.info("INFO: ViewModel.loadCategoryGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }

    func unloadCategoryGroup() {
        categoryGroup.unload()
    }
}
