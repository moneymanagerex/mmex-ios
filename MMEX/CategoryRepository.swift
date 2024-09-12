//
//  CategoryRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SQLite

class CategoryRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }

    // Load all categories
    func loadCategories() -> [Category] {
        var categories: [Category] = []
        guard let db = db else { return [] }

        do {
            for category in try db.prepare(Category.table) {
                let categoryObj = Category(
                    id: category[Category.categID],
                    name: category[Category.categName],
                    active: category[Category.activeExpr] == 1, // Convert int to bool
                    parentId: category[Category.parentID]
                )
                categories.append(categoryObj)
            }
        } catch {
            print("Error loading categories: \(error)")
        }

        return categories
    }

    // Update an existing category
    func updateCategory(category: Category) -> Bool {
        let categoryToUpdate = Category.table.filter(Category.categID == category.id)
        do {
            try db?.run(categoryToUpdate.update(
                Category.categName <- category.name,
                Category.activeExpr <- ((category.active ?? false) ? 1 : 0), // Convert bool to int
                Category.parentID <- category.parentId
            ))
            return true
        } catch {
            print("Failed to update category: \(error)")
            return false
        }
    }

    // Delete a category
    func deleteCategory(category: Category) -> Bool {
        let categoryToDelete = Category.table.filter(Category.categID == category.id)
        do {
            try db?.run(categoryToDelete.delete())
            return true
        } catch {
            print("Failed to delete category: \(error)")
            return false
        }
    }

    // Add a new category
    func addCategory(category: inout Category) -> Bool {
        do {
            let insert = Category.table.insert(
                Category.categName <- category.name,
                Category.activeExpr <- ((category.active ?? false) ? 1 : 0), // Convert bool to int
                Category.parentID <- category.parentId
            )
            let rowid = try db?.run(insert)
            category.id = rowid! // Update the category ID with the inserted row ID
            print("Successfully added category: \(category.name), \(category.id)")
            return true
        } catch {
            print("Failed to add category: \(error)")
            return false
        }
    }
}
