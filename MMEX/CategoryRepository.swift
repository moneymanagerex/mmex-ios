//
//  CategoryRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class CategoryRepository {
    private let db: Connection?

    init(db: Connection?) {
        self.db = db
    }

    // Load Categories
    func loadCategories() -> [Category] {
        var categories: [Category] = []
        guard let db = db else { return [] }
        
        do {
            for category in try db.prepare(Category.table) {
                categories.append(Category(
                    id: category[Category.categID],
                    name: category[Category.categName],
                    active: category[Category.activeExpr] == 1,
                    parentId: category[Category.parentID]
                ))
            }
        } catch {
            print("Error loading categories: \(error)")
        }
        return categories
    }

    // Add Category
    func addCategory(category: inout Category) -> Bool {
        guard let db = db else { return false }

        do {
            let insert = Category.table.insert(
                Category.categName <- category.name,
                Category.activeExpr <- (category.active ? 1 : 0),
                Category.parentID <- category.parentId
            )
            let rowid = try db.run(insert)
            category.id = rowid
            return true
        } catch {
            print("Failed to add category: \(error)")
            return false
        }
    }

    // Update Category
    func updateCategory(category: Category) -> Bool {
        guard let db = db else { return false }

        let categoryToUpdate = Category.table.filter(Category.categID == category.id)
        do {
            try db.run(categoryToUpdate.update(
                Category.categName <- category.name,
                Category.activeExpr <- (category.active ? 1 : 0),
                Category.parentID <- category.parentId
            ))
            return true
        } catch {
            print("Failed to update category: \(error)")
            return false
        }
    }

    // Delete Category
    func deleteCategory(category: Category) -> Bool {
        guard let db = db else { return false }

        let categoryToDelete = Category.table.filter(Category.categID == category.id)
        do {
            try db.run(categoryToDelete.delete())
            return true
        } catch {
            print("Failed to delete category: \(error)")
            return false
        }
    }
}
