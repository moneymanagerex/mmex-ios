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
    
}

extension CategoryRepository {
    // table query
    static let table = Table("CATEGORY_V1")
    
    // table columns
    static let col_id       = Expression<Int64>("CATEGID")
    static let col_name     = Expression<String>("CATEGNAME")
    static let col_active   = Expression<Int?>("ACTIVE")
    static let col_parentId = Expression<Int64?>("PARENTID")
}

extension CategoryRepository {
    // select query
    static let selectQuery = table.select(
        col_id,
        col_name,
        col_active,
        col_parentId
    )
    
    // select result
    static func selectResult(_ row: Row) -> Category {
        return Category(
            id       : row[col_id],
            name     : row[col_name],
            active   : row[col_active] ?? 0 == 1,
            parentId : row[col_parentId]
        )
    }
    
    // insert query
    static func insertQuery(_ category: Category) -> Insert {
        return table.insert(
            col_name     <- category.name,
            col_active   <- category.active ?? false ? 1 : 0,
            col_parentId <- category.parentId
        )
    }

    // update query
    static func updateQuery(_ category: Category) -> Update {
        return table.filter(col_id == category.id).update(
            col_name     <- category.name,
            col_active   <- category.active ?? false ? 1 : 0,
            col_parentId <- category.parentId
        )
    }
    
    // delete query
    static func deleteQuery(_ category: Category) -> Delete {
        return table.filter(col_id == category.id).delete()
    }
}

extension CategoryRepository {
    // load all categories
    func loadCategories() -> [Category] {
        guard let db = db else { return [] }
        do {
            var categories: [Category] = []
            for row in try db.prepare(CategoryRepository.selectQuery) {
                categories.append(CategoryRepository.selectResult(row))
            }
            print("Successfully loaded categories: \(categories.count)")
            return categories
        } catch {
            print("Error loading categories: \(error)")
            return []
        }
    }

    // add a new category
    func addCategory(category: inout Category) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(CategoryRepository.insertQuery(category))
            category.id = rowid // Update the category ID with the inserted row ID
            print("Successfully added category: \(category.name), \(category.id)")
            return true
        } catch {
            print("Failed to add category: \(error)")
            return false
        }
    }

    // update an existing category
    func updateCategory(category: Category) -> Bool {
        guard let db else { return false }
        do {
            try db.run(CategoryRepository.updateQuery(category))
            print("Successfully updated category: \(category.name), \(category.id)")
            return true
        } catch {
            print("Failed to update category: \(error)")
            return false
        }
    }

    // delete a category
    func deleteCategory(category: Category) -> Bool {
        guard let db else { return false }
        do {
            try db.run(CategoryRepository.deleteQuery(category))
            print("Successfully deleted category: \(category.name), \(category.id)")
            return true
        } catch {
            print("Failed to delete category: \(error)")
            return false
        }
    }
}
