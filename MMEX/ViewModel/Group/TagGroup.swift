//
//  TagGroup.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum TagGroupChoice: String, GroupChoiceProtocol {
    case all    = "All"
    case used   = "Used"
    case active = "Active"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct TagGroup: GroupProtocol {
    typealias MainRepository = TagRepository
    typealias GroupChoice    = TagGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.tag"
    }

    static let groupUsed   : [Bool] = [true, false]
    static let groupActive : [Bool] = [true, false]
}

extension ViewModel {
    func loadTagGroup(choice: TagGroupChoice) {
        guard
            let listData    = tagList.data.readyValue,
            let listUsed    = tagList.used.readyValue,
            let listOrder   = tagList.order.readyValue
        else { return }

        guard tagGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadTagGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        tagGroup.choice = choice
        tagGroup.search = false

        switch choice {
        case .all:
            tagGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in TagGroup.groupUsed {
                let name = g ? "Used" : "Other"
                tagGroup.append(name, dict[g] ?? [], true, g)
            }
        case .active:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.active }
            for g in TagGroup.groupActive {
                let name = g ? "Active" : "Other"
                tagGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        tagGroup.state.loaded()
        log.info("INFO: ViewModel.loadTagGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
