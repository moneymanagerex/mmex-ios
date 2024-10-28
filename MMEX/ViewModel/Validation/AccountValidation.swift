//
//  AccountValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateAccount(_ data: inout AccountData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        guard data.currencyId > 0 else {
            return "No currency is selected"
        }
        guard let currencyName = currencyList.name.readyValue else {
            return "* currencyName is not loaded"
        }
        if currencyName[data.currencyId] == nil {
            return "* Unknown currency #\(data.currencyId)"
        }

        guard let a = A(env) else {
            return "* Database is not available"
        }

        guard let dataName = a.selectId(from: A.table.filter(
            A.table[A.col_id] == Int64(data.id) || A.table[A.col_name] == data.name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id <= 0 ? 0 : 1) else {
            return "Account \(data.name) already exists"
        }

        if data.id <= 0 {
            guard a.insert(&data) else {
                return "* Cannot create new account"
            }
        } else {
            guard a.update(data) else {
                return "* Cannot update account #\(data.id)"
            }
        }

        return nil
    }

    func deleteAccount(_ data: AccountData) -> String? {
        guard let accountUsed = accountList.used.readyValue else {
            return "* accountUsed is not loaded"
        }
        if accountUsed.contains(data.id) {
            return "* Account #\(data.id) is used"
        }

        guard let a = A(env), let ax = AX(env) else {
            return "* Database is not available"
        }

        guard let accountAtt = accountList.att.readyValue else {
            return "* accountAtt is not loaded"
        }
        if accountAtt[data.id] != nil {
            guard ax.delete(refType: .account, refId: data.id) else {
                return "* Cannot delete attachments for account #\(data.id)"
            }
        }

        guard a.delete(data) else {
            return "* Cannot delete account #\(data.id)"
        }

        return nil
    }
}
