//
//  BudgetPeriodSaerch.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetPeriodSearch: SearchProtocol {
    var area: [SearchArea<BudgetPeriodData>] = [
        ("Name", true, {[ $0.name ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func budgetPeriodGroupIsVisible(_ g: Int, search: BudgetPeriodSearch) -> Bool? {
        guard
            let listData  = budgetPeriodList.data.readyValue,
            let groupData = budgetPeriodGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch budgetPeriodGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchBudgetPeriodGroup(search: BudgetPeriodSearch, expand: Bool = false) {
        if budgetPeriodGroup.search { return }
        guard budgetPeriodGroup.state == .ready else { return }
        log.trace("DEBUG: ViewModel.searchBudgetPeriodGroup(\(search.key), main=\(Thread.isMainThread))")
        for g in 0 ..< budgetPeriodGroup.value.count {
            guard let isVisible = budgetPeriodGroupIsVisible(g, search: search) else { return }
            budgetPeriodGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                budgetPeriodGroup.value[g].isExpanded = true
            }
        }
        budgetPeriodGroup.search = true
    }
}
