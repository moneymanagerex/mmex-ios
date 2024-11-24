//
//  BudgetValidation.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateBudget(_ data: inout BudgetData) -> String? {
        if data.periodId.isVoid {
            return "Budget period is not defined"
        } else {
            guard let budgetPeriodData = budgetPeriodList.data.readyValue else {
                return "* budgetPeriodData is not loaded"
            }
            if budgetPeriodData[data.periodId] == nil {
                return "* Unknown budget period #\(data.periodId.value)"
            }
        }

        if data.categoryId.isVoid {
            return "Category is not defined"
        } else {
            guard let categoryData = categoryList.data.readyValue else {
                return "* categoryData is not loaded"
            }
            if categoryData[data.categoryId] == nil {
                return "* Unknown category #\(data.categoryId.value)"
            }
        }

        guard let b = B(self) else {
            return "* Database is not available"
        }

        guard let dataKey = b.selectId(from: B.table.filter(
            B.table[B.col_id] == Int64(data.id) ||
            (B.table[B.col_yearId] == Int64(data.periodId) && B.table[B.col_categId] == Int64(data.categoryId))
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataKey.count == (data.id.isVoid ? 0 : 1) else {
            // MMEX Desktop supports only unique (periodId, categoryId)
            return "Budget key (period, category) already exists"
        }

        if data.id.isVoid {
            guard b.insert(&data) else {
                return "* Cannot create new budget"
            }
        } else {
            guard b.update(data) else {
                return "* Cannot update budget #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteBudget(_ data: BudgetData) -> String? {
        guard let budgetUsed = budgetList.used.readyValue else {
            return "* budgetUsed is not loaded"
        }
        if budgetUsed.contains(data.id) {
            return "* Budget #\(data.id.value) is used"
        }

        guard let b = B(self) else {
            return "* Database is not available"
        }

        guard b.delete(data) else {
            return "* Cannot delete budget #\(data.id.value)"
        }

        return nil
    }
}
