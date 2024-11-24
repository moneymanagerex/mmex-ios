//
//  TagValidation.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension TagData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        typealias G = ViewModel.G
        guard let g = G(vm) else {
            return "* Database is not available"
        }

        guard let dataName = g.selectId(from: G.table.filter(
            G.table[G.col_id] == Int64(id) ||
            G.table[G.col_name] == name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Tag \(name) already exists"
        }

        if id.isVoid {
            guard g.insert(&self) else {
                return "* Cannot create new tag"
            }
        } else {
            guard g.update(self) else {
                return "* Cannot update tag #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let tagUsed = vm.tagList.used.readyValue else {
            return "* tagUsed is not loaded"
        }
        if tagUsed.contains(id) {
            return "* Tag #\(id.value) is used"
        }

        typealias G = ViewModel.G
        guard let g = G(vm) else {
            return "* Database is not available"
        }

        guard g.delete(self) else {
            return "* Cannot delete tag #\(id.value)"
        }

        return nil
    }
}
