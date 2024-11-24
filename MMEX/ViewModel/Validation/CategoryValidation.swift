//
//  CategoryValidation.swift
//  MMEX
//
//  2024-11-18: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension CategoryData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        if !id.isVoid, !parentId.isVoid {
            guard let categoryTree = vm.categoryList.evalTree.readyValue else {
                return "* currencyTree is not loaded"
            }
            guard
                let i = categoryTree.indexById[id],
                let p = categoryTree.indexById[parentId]
            else {
                return "* currencyTree does not contain #\(id.value) and #\(parentId.value)"
            }
            if p >= i, p < categoryTree.order[i].next {
                return "Parent category #\(parentId.value) is under category #\(id.value)"
            }
        }

        typealias C = ViewModel.C
        guard let c = C(vm) else {
            return "* Database is not available"
        }

        guard let dataName = c.selectId(from: C.table.filter(
            C.table[C.col_id] == Int64(id) || (
                C.table[C.col_parentId] == Int64(parentId) &&
                C.table[C.col_name] == name
            )
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Category \(name) already exists"
        }

        if id.isVoid {
            guard c.insert(&self) else {
                return "* Cannot create new category"
            }
        } else {
            guard c.update(self) else {
                return "* Cannot update category #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let categoryUsed = vm.categoryList.used.readyValue else {
            return "* categoryUsed is not loaded"
        }
        if categoryUsed.contains(id) {
            return "* Category #\(id.value) is used"
        }

        guard let categoryTree = vm.categoryList.evalTree.readyValue else {
            return "* categoryTree is not loaded"
        }
        if categoryTree.childrenById[id] != nil {
            return "* Category #\(id.value) has sub-categories"
        }

        typealias C = ViewModel.C
        guard let c = C(vm) else {
            return "* Database is not available"
        }

        guard c.delete(self) else {
            return "* Cannot delete category #\(id.value)"
        }

        return nil
    }
}
