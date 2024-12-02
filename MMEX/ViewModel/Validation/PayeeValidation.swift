//
//  PayeeValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension PayeeData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        if !categoryId.isVoid {
            guard let categoryData = vm.categoryList.data.readyValue else {
                return "* categoryData is not loaded"
            }
            if categoryData[categoryId] == nil {
                return "* Unknown category #\(categoryId.value)"
            }
        }

        typealias P = ViewModel.P
        guard let p = P(vm.db) else {
            return "* Database is not available"
        }

        guard let dataName = p.selectId(from: P.table.filter(
            P.table[P.col_id] == Int64(id) ||
            P.table[P.col_name] == name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Payee \(name) already exists"
        }

        if id.isVoid {
            guard p.insert(&self) else {
                return "* Cannot create new payee"
            }
        } else {
            guard p.update(self) else {
                return "* Cannot update payee #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let payeeUsed = vm.payeeList.used.readyValue else {
            return "* payeeUsed is not loaded"
        }
        if payeeUsed.contains(id) {
            return "* Payee #\(id.value) is used"
        }

        typealias P = ViewModel.P
        typealias D = ViewModel.D
        guard let p = P(vm.db), let d = D(vm.db) else {
            return "* Database is not available"
        }

        guard let payeeAtt = vm.payeeList.attachment.readyValue else {
            return "* payeeAtt is not loaded"
        }
        if payeeAtt[id] != nil {
            guard d.delete(refType: .payee, refId: id) else {
                return "* Cannot delete attachments for payee #\(id.value)"
            }
        }

        guard p.delete(self) else {
            return "* Cannot delete payee #\(id.value)"
        }

        return nil
    }
}
