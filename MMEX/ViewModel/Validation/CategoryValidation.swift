//
//  CategoryValidation.swift
//  MMEX
//
//  2024-11-18: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func copyCategory(_ data: inout CategoryData) {
        data.name.append(" (Copy)")
    }

    func updateCategory(_ data: inout CategoryData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        if !data.id.isVoid, !data.parentId.isVoid {
            guard let categoryTree = categoryList.evalTree.readyValue else {
                return "* currencyTree is not loaded"
            }
            guard
                let i = categoryTree.indexById[data.id],
                let p = categoryTree.indexById[data.parentId]
            else {
                return "* currencyTree does not contain #\(data.id.value) and #\(data.parentId.value)"
            }
            if p >= i, p < categoryTree.order[i].next {
                return "Parent category #\(data.parentId.value) is under category #\(data.id.value)"
            }
        }

        guard let c = C(self) else {
            return "* Database is not available"
        }

        guard let dataName = c.selectId(from: C.table.filter(
            C.table[C.col_id] == Int64(data.id) || (
                C.table[C.col_parentId] == Int64(data.parentId) &&
                C.table[C.col_name] == data.name
            )
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id.isVoid ? 0 : 1) else {
            return "Category \(data.name) already exists"
        }

        if data.id.isVoid {
            guard c.insert(&data) else {
                return "* Cannot create new category"
            }
        } else {
            guard c.update(data) else {
                return "* Cannot update category #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteCategory(_ data: CategoryData) -> String? {
        guard let categoryUsed = categoryList.used.readyValue else {
            return "* categoryUsed is not loaded"
        }
        if categoryUsed.contains(data.id) {
            return "* Category #\(data.id.value) is used"
        }

        guard let categoryTree = categoryList.evalTree.readyValue else {
            return "* categoryTree is not loaded"
        }
        if categoryTree.childrenById[data.id] != nil {
            return "* Category #\(data.id.value) has sub-categories"
        }

        guard let c = C(self) else {
            return "* Database is not available"
        }

        guard c.delete(data) else {
            return "* Cannot delete category #\(data.id.value)"
        }

        return nil
    }
}
