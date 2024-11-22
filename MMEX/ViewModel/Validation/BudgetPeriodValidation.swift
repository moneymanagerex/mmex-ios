//
//  BudgetPeriodValidation.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func copyBudgetPeriod(_ data: inout BudgetPeriodData) {
        data.name.append(" (Copy)")
    }

    func updateBudgetPeriod(_ data: inout BudgetPeriodData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        guard let bp = BP(env) else {
            return "* Database is not available"
        }

        guard let dataName = bp.selectId(from: G.table.filter(
            G.table[G.col_id] == Int64(data.id) ||
            G.table[G.col_name] == data.name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id.isVoid ? 0 : 1) else {
            return "Budget period \(data.name) already exists"
        }

        if data.id.isVoid {
            guard bp.insert(&data) else {
                return "* Cannot create new budget period"
            }
        } else {
            guard bp.update(data) else {
                return "* Cannot update budget period #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteBudgetPeriod(_ data: BudgetPeriodData) -> String? {
        guard let budgetPeriodUsed = budgetPeriodList.used.readyValue else {
            return "* budgetPeriodUsed is not loaded"
        }
        if budgetPeriodUsed.contains(data.id) {
            return "* Budget period #\(data.id.value) is used"
        }

        guard let bp = BP(env) else {
            return "* Database is not available"
        }

        guard bp.delete(data) else {
            return "* Cannot delete budget period #\(data.id.value)"
        }

        return nil
    }
}
