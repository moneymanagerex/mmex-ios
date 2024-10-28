//
//  PayeeValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updatePayee(_ data: inout PayeeData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        if data.categoryId > 0 {
            guard let categoryData = categoryList.data.readyValue else {
                return "* categoryData is not loaded"
            }
            if categoryData[data.categoryId] == nil {
                return "* Unknown category #\(data.categoryId)"
            }
        }

        guard let p = P(env) else {
            return "* Database is not available"
        }

        guard let dataName = p.selectId(from: P.table.filter(
            P.table[P.col_id] == Int64(data.id) ||
            P.table[P.col_name] == data.name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id <= 0 ? 0 : 1) else {
            return "Payee \(data.name) already exists"
        }

        if data.id <= 0 {
            guard p.insert(&data) else {
                return "* Cannot create new payee"
            }
        } else {
            guard p.update(data) else {
                return "* Cannot update payee #\(data.id)"
            }
        }

        return nil
    }

    func deletePayee(_ data: PayeeData) -> String? {
        guard let payeeUsed = payeeList.used.readyValue else {
            return "* payeeUsed is not loaded"
        }
        if payeeUsed.contains(data.id) {
            return "* Payee #\(data.id) is used"
        }

        guard let p = P(env), let ax = AX(env) else {
            return "* Database is not available"
        }

        guard let payeeAtt = payeeList.att.readyValue else {
            return "* payeeAtt is not loaded"
        }
        if payeeAtt[data.id] != nil {
            guard ax.delete(refType: .payee, refId: data.id) else {
                return "* Cannot delete attachments for payee #\(data.id)"
            }
        }

        guard p.delete(data) else {
            return "* Cannot delete payee #\(data.id)"
        }

        return nil
    }
}
