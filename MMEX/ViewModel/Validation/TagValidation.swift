//
//  TagValidation.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func copyTag(_ data: inout TagData) {
        data.name.append(" (Copy)")
    }

    func updateTag(_ data: inout TagData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        guard let g = G(env) else {
            return "* Database is not available"
        }

        guard let dataName = g.selectId(from: G.table.filter(
            G.table[G.col_id] == Int64(data.id) ||
            G.table[G.col_name] == data.name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id.isVoid ? 0 : 1) else {
            return "Tag \(data.name) already exists"
        }

        if data.id.isVoid {
            guard g.insert(&data) else {
                return "* Cannot create new tag"
            }
        } else {
            guard g.update(data) else {
                return "* Cannot update tag #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteTag(_ data: TagData) -> String? {
        guard let tagUsed = tagList.used.readyValue else {
            return "* tagUsed is not loaded"
        }
        if tagUsed.contains(data.id) {
            return "* Tag #\(data.id.value) is used"
        }

        guard let g = G(env) else {
            return "* Database is not available"
        }

        guard g.delete(data) else {
            return "* Cannot delete tag #\(data.id.value)"
        }

        return nil
    }
}
