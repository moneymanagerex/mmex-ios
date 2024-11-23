//
//  FieldValidation.swift
//  MMEX
//
//  2024-11-23: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func copyField(_ data: inout FieldData) {
    }

    func updateField(_ data: inout FieldData) -> String? {
        guard let f = F(env) else {
            return "* Database is not available"
        }

        if data.id.isVoid {
            guard f.insert(&data) else {
                return "* Cannot create new field"
            }
        } else {
            guard f.update(data) else {
                return "* Cannot update field #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteField(_ data: FieldData) -> String? {
        guard let fieldUsed = fieldList.used.readyValue else {
            return "* fieldUsed is not loaded"
        }
        if fieldUsed.contains(data.id) {
            return "* Field #\(data.id.value) is used"
        }

        guard let f = F(env) else {
            return "* Database is not available"
        }

        guard f.delete(data) else {
            return "* Cannot delete field #\(data.id.value)"
        }

        return nil
    }
}
