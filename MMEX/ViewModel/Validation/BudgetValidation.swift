//
//  BudgetValidation.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension BudgetData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if periodId.isVoid {
            return "Budget period is not defined"
        } else {
            guard let budgetPeriodData = vm.budgetPeriodList.data.readyValue else {
                return "* budgetPeriodData is not loaded"
            }
            if budgetPeriodData[periodId] == nil {
                return "* Unknown budget period #\(periodId.value)"
            }
        }

        if categoryId.isVoid {
            return "Category is not defined"
        } else {
            guard let categoryData = vm.categoryList.data.readyValue else {
                return "* categoryData is not loaded"
            }
            if categoryData[categoryId] == nil {
                return "* Unknown category #\(categoryId.value)"
            }
        }

        typealias B = ViewModel.B
        guard let b = B(vm) else {
            return "* Database is not available"
        }

        guard let dataKey = b.selectId(from: B.table.filter(
            B.table[B.col_id] == Int64(id) ||
            (B.table[B.col_yearId] == Int64(periodId) && B.table[B.col_categId] == Int64(categoryId))
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataKey.count == (id.isVoid ? 0 : 1) else {
            // MMEX Desktop supports only unique (periodId, categoryId)
            return "Budget key (period, category) already exists"
        }

        if id.isVoid {
            guard b.insert(&self) else {
                return "* Cannot create new budget"
            }
        } else {
            guard b.update(self) else {
                return "* Cannot update budget #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let budgetUsed = vm.budgetList.used.readyValue else {
            return "* budgetUsed is not loaded"
        }
        if budgetUsed.contains(id) {
            return "* Budget #\(id.value) is used"
        }

        typealias B = ViewModel.B
        guard let b = B(vm) else {
            return "* Database is not available"
        }

        guard b.delete(self) else {
            return "* Cannot delete budget #\(id.value)"
        }

        return nil
    }
}
