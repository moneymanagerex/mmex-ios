//
//  FieldGroup.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum FieldGroupChoice: String, GroupChoiceProtocol {
    case all     = "All"
    case used    = "Used"
    case refType = "Ref. Type"
    case type    = "Field Type"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct FieldGroup: GroupProtocol {
    typealias MainRepository = FieldRepository
    typealias GroupChoice    = FieldGroupChoice
    let idleValue: ValueType = []

    @Preference var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.field"
    }

    static let groupUsed: [Bool] = [
        true, false
    ]

    static let groupRefType: [RefType] = [
        .transaction, .scheduled
    ]

    static let groupType: [FieldType] = [
        .string, .integer, .decimal, .boolean, .date, .time,
        .singleChoice, .multiChoice, .unknown
    ]
}

extension ViewModel {
    func loadFieldGroup(choice: FieldGroupChoice) {
        guard
            let listData    = fieldList.data.readyValue,
            let listUsed    = fieldList.used.readyValue,
            let listOrder   = fieldList.order.readyValue
        else { return }

        guard fieldGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadFieldGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        fieldGroup.choice = choice

        switch choice {
        case .all:
            fieldGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in FieldGroup.groupUsed {
                let name = g ? "Used" : "Other"
                fieldGroup.append(name, dict[g] ?? [], true, g)
            }
        case .refType:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.refType }
            for g in FieldGroup.groupRefType {
                fieldGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in FieldGroup.groupType {
                fieldGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        }

        fieldGroup.state.loaded()
        log.info("INFO: ViewModel.loadFieldGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }

    func unloadFieldGroup() {
        fieldGroup.unload()
    }
}
