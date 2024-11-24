//
//  AccountValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension AccountData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        guard !currencyId.isVoid else {
            return "No currency is selected"
        }
        guard let currencyName = vm.currencyList.name.readyValue else {
            return "* currencyName is not loaded"
        }
        if currencyName[currencyId] == nil {
            return "* Unknown currency #\(currencyId.value)"
        }

        typealias A = ViewModel.A
        guard let a = A(vm.db) else {
            return "* Database is not available"
        }

        guard let dataName = a.selectId(from: A.table.filter(
            A.table[A.col_id] == Int64(id) ||
            A.table[A.col_name] == name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Account \(name) already exists"
        }

        if id.isVoid {
            guard a.insert(&self) else {
                return "* Cannot create new account"
            }
        } else {
            guard a.update(self) else {
                return "* Cannot update account #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let accountUsed = vm.accountList.used.readyValue else {
            return "* accountUsed is not loaded"
        }
        if accountUsed.contains(id) {
            return "* Account #\(id.value) is used"
        }

        typealias A = ViewModel.A
        typealias D = ViewModel.D
        guard let a = A(vm.db), let d = D(vm.db) else {
            return "* Database is not available"
        }

        guard let accountAtt = vm.accountList.att.readyValue else {
            return "* accountAtt is not loaded"
        }
        if accountAtt[id] != nil {
            guard d.delete(refType: .account, refId: id) else {
                return "* Cannot delete attachments for account #\(id.value)"
            }
        }

        guard a.delete(self) else {
            return "* Cannot delete account #\(id.value)"
        }

        return nil
    }
}
