//
//  BudgetPeriodValidation.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension BudgetPeriodData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        typealias BP = ViewModel.BP
        guard let bp = BP(vm.db) else {
            return "* Database is not available"
        }

        guard let dataName = bp.selectId(from: BP.table.filter(
            BP.table[BP.col_id] == Int64(id) ||
            BP.table[BP.col_name] == name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Budget period \(name) already exists"
        }

        if id.isVoid {
            guard bp.insert(&self) else {
                return "* Cannot create new budget period"
            }
        } else {
            guard bp.update(self) else {
                return "* Cannot update budget period #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let budgetPeriodUsed = vm.budgetPeriodList.used.readyValue else {
            return "* budgetPeriodUsed is not loaded"
        }
        if budgetPeriodUsed.contains(id) {
            return "* Budget period #\(id.value) is used"
        }

        typealias BP = ViewModel.BP
        guard let bp = BP(vm.db) else {
            return "* Database is not available"
        }

        guard bp.delete(self) else {
            return "* Cannot delete budget period #\(id.value)"
        }

        return nil
    }
}
