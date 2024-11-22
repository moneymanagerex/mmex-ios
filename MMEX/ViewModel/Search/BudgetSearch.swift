//
//  BudgetSearch.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetSearch: SearchProtocol {
    var area: [SearchArea<BudgetData>] = [
        ("Period",     true,  nil, { vm, data in
            vm.budgetPeriodList.data.readyValue?[data.periodId].map { [$0.name] } ?? []
        } ),
        ("Category",   false, nil, { vm, data in
            vm.categoryList.evalPath.readyValue?[data.categoryId].map { [$0] } ?? []
        } ),
        ("Notes",      false, {[ $0.notes ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func budgetGroupIsVisible(_ g: Int, search: BudgetSearch) -> Bool? {
        guard
            let listData  = budgetList.data.readyValue,
            let groupData = budgetGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch budgetGroup.choice {
            case .period, .category: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchBudgetGroup(search: BudgetSearch, expand: Bool = false) {
        if budgetGroup.search { return }
        guard budgetGroup.state == .ready else { return }
        log.trace("DEBUG: ViewModel.searchBudgetGroup(\(search.key), main=\(Thread.isMainThread))")
        for g in 0 ..< budgetGroup.value.count {
            guard let isVisible = budgetGroupIsVisible(g, search: search) else { return }
            budgetGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                budgetGroup.value[g].isExpanded = true
            }
        }
        budgetGroup.search = true
    }
}
