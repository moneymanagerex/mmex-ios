//
//  ReportGroup.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum ReportGroupChoice: String, GroupChoiceProtocol {
    case all    = "All"
    case active = "Active"
    case group  = "Group"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct ReportGroup: GroupProtocol {
    typealias MainRepository = ReportRepository
    typealias GroupChoice    = ReportGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
        self.$choice = "manage.group.report"
    }

    static let groupActive: [Bool] = [true, false]

    var groupGroup: [String] = []
}

extension ViewModel {
    func loadReportGroup(choice: ReportGroupChoice) {
        guard
            let listData      = reportList.data.readyValue,
            let listOrder     = reportList.order.readyValue
        else { return }

        guard reportGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadReportGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        reportGroup.choice = choice
        stockGroup.search = false
        reportGroup.groupGroup = []

        switch choice {
        case .all:
            reportGroup.append("All", listOrder, true, true)
        case .active:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.active }
            for g in ReportGroup.groupActive {
                let name = g ? "Active" : "Other"
                reportGroup.append(name, dict[g] ?? [], true, g)
            }
        case .group:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.groupName }
            reportGroup.groupGroup = dict.keys.sorted()
            for g in reportGroup.groupGroup {
                let name = !g.isEmpty ? g : "(none)"
                reportGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        }

        reportGroup.state.loaded()
        log.info("INFO: ViewModel.loadReportGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}
