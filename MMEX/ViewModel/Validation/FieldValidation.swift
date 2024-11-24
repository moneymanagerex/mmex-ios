//
//  FieldValidation.swift
//  MMEX
//
//  2024-11-23: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension FieldData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        typealias F = ViewModel.F
        guard let f = F(vm.db) else {
            return "* Database is not available"
        }

        if id.isVoid {
            guard f.insert(&self) else {
                return "* Cannot create new field"
            }
        } else {
            guard f.update(self) else {
                return "* Cannot update field #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let fieldUsed = vm.fieldList.used.readyValue else {
            return "* fieldUsed is not loaded"
        }
        if fieldUsed.contains(id) {
            return "* Field #\(id.value) is used"
        }

        typealias F = ViewModel.F
        guard let f = F(vm.db) else {
            return "* Database is not available"
        }

        guard f.delete(self) else {
            return "* Cannot delete field #\(id.value)"
        }

        return nil
    }
}
