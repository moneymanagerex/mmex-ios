//
//  ScheduledValidation.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI
import SQLite

extension ScheduledData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        // 基本验证
        if accountId.isVoid {
            return "Account is required"
        }
        if transCode == .transfer && toAccountId.isVoid {
            return "To Account is required for transfers"
        }
        if transCode != .transfer && payeeId.isVoid {
            return "Payee is required"
        }
        if transAmount == 0 {
            return "Amount cannot be zero"
        }
        if dueDate.string.isEmpty {
            return "Due date is required"
        }

        // 类型验证：确保账户存在
        guard let accountData = vm.accountList.data.readyValue else {
            return "* accountData is not loaded"
        }
        if accountData[accountId] == nil {
            return "* Unknown account #\(accountId.value)"
        }
        if !toAccountId.isVoid && accountData[toAccountId] == nil {
            return "* Unknown to-account #\(toAccountId.value)"
        }

        // 如果是转账，不需要 payee
        if transCode != .transfer {
            guard let payeeData = vm.payeeList.data.readyValue else {
                return "* payeeData is not loaded"
            }
            if payeeData[payeeId] == nil {
                return "* Unknown payee #\(payeeId.value)"
            }
        }

        // 如果分类不为空，验证分类是否存在
        if !categId.isVoid {
            guard let categoryData = vm.categoryList.data.readyValue else {
                return "* categoryData is not loaded"
            }
            if categoryData[categId] == nil {
                return "* Unknown category #\(categId.value)"
            }
        }

        // 数据库操作
        typealias Q = ViewModel.Q
        guard let q = Q(vm.db) else {
            return "* Database is not available"
        }

        if id.isVoid {
            guard q.insert(&self) else {
                return "* Cannot create new scheduled transaction"
            }
        } else {
            guard q.update(self) else {
                return "* Cannot update scheduled transaction #\(id.value)"
            }
        }

        if transAmount == 0 { return "Amount cannot be zero" }

        if transCode == .transfer {
            guard !toAccountId.isVoid else { return "To Account is required for transfers" }
            if toAccountId == accountId { return "To Account cannot be the same as Account" }
        }

        if !splits.isEmpty {
            let total = splits.reduce(0) { $0 + $1.amount }
            if abs(abs(total) - transAmount) > 0.000001 {
                return "Split amounts must sum to the transaction amount"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        // 检查是否被使用（例如，是否有未来的交易链接？暂时只检查基本条件）
        // 由于 scheduled 交易本身是独立的，可能没有直接的使用检查，可以允许删除
        // 但如果有 tag 或 attachment 关联，可能需要先清理
        // 我们简单检查是否有 splits 或 tags

        typealias Q = ViewModel.Q
        guard let q = Q(vm.db) else {
            return "* Database is not available"
        }

        // 如果有 splits，先删除它们（但通常在数据库级联删除或由 Repository 处理）
        // 为了安全，我们直接删除主记录，依赖外键级联（如果有）
        guard q.delete(self) else {
            return "* Cannot delete scheduled transaction #\(id.value)"
        }

        return nil
    }
}
