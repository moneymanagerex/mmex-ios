//
//  ScheduledGroup.swift
//  MMEX
//
//  2024-12-02: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum ScheduledGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case auto       = "Auto"
    case last       = "Last"
    case status     = "Status"
    case account    = "Account"
    case category   = "Category"
    case tag        = "Tag"
    case attachment = "Attachment"
    case split      = "Split"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct ScheduledGroup: GroupProtocol {
    typealias MainRepository = ScheduledRepository
    typealias GroupChoice    = ScheduledGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
        self.$choice = "manage.group.scheduled"
    }

    static let groupAuto   : [RepeatAuto] = RepeatAuto.allCases
    static let groupLast   : [Bool] = [true, false]
    static let groupStatus : [TransactionStatus] = TransactionStatus.allCases
    static let groupTag    : [Bool] = [true, false]
    static let groupAtt    : [Bool] = [true, false]
    static let groupSplit  : [Bool] = [true, false]

    var groupAccount  : [DataId] = []
    var groupCategory : [DataId] = []
}

extension ViewModel {
    func loadScheduledGroup(choice: ScheduledGroupChoice) {
        guard
            let listData      = scheduledList.data.readyValue,
            let listOrder     = scheduledList.order.readyValue,
            let listTagLink   = scheduledList.tagLink.readyValue,
            let listAtt       = scheduledList.attachment.readyValue,
            let listSplit     = scheduledList.split.readyValue,
            let accountData   = accountList.data.readyValue,
            let accountOrder  = accountList.order.readyValue,
            let categoryPath  = categoryList.evalPath.readyValue,
            let categoryOrder = categoryList.evalTree.readyValue?.order
        else { return }

        guard scheduledGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadScheduledGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        scheduledGroup.choice = choice
        stockGroup.search = false
        scheduledGroup.groupCategory = []

        switch choice {
        case .all:
            scheduledGroup.append("All", listOrder, true, true)
        case .auto:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.repeatAuto }
            for g in ScheduledGroup.groupAuto {
                scheduledGroup.append(g.name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .last:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.repeatTypeNum?.num == 1 }
            for g in ScheduledGroup.groupLast {
                let name = g ? "Last" : "Other"
                scheduledGroup.append(name, dict[g] ?? [], true, g)
            }
        case .status:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.status }
            for g in ScheduledGroup.groupStatus {
                scheduledGroup.append(g.fullName, dict[g] ?? [], dict[g] != nil, true)
            }
        case .account:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.accountId }
            scheduledGroup.groupAccount = accountOrder.compactMap {
                dict[$0] != nil ? $0 : nil
            }
            for g in scheduledGroup.groupAccount {
                let name = accountData[g]?.name
                scheduledGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .category:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.categId }
            scheduledGroup.groupCategory = [.void] + categoryOrder.compactMap {
                dict[$0.dataId] != nil ? $0.dataId : nil
            }
            for g in scheduledGroup.groupCategory {
                let name = g == .void ? "(none)" : categoryPath[g] ?? "(unknown)"
                scheduledGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .tag:
            let dict = Dictionary(grouping: listOrder) { listTagLink[$0]?.count ?? 0 > 0 }
            for g in ScheduledGroup.groupTag {
                let name = g ? "With Tag" : "Other"
                scheduledGroup.append(name, dict[g] ?? [], true, g)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in ScheduledGroup.groupAtt {
                let name = g ? "With Attachment" : "Other"
                scheduledGroup.append(name, dict[g] ?? [], true, g)
            }
        case .split:
            let dict = Dictionary(grouping: listOrder) { listSplit[$0] != nil }
            for g in ScheduledGroup.groupSplit {
                let name = g ? "With Split" : "Other"
                scheduledGroup.append(name, dict[g] ?? [], true, g)
            }
        }

        scheduledGroup.state.loaded()
        log.info("INFO: ViewModel.loadScheduledGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
