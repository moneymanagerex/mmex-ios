//
//  RepositoryProtocaol.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

protocol RepositoryProtocol {
    associatedtype RepositoryItem: ModelProtocol

    static var repositoryName: String { get }
    static var table: SQLite.Table { get }
    static func selectQuery(from table: SQLite.Table) -> SQLite.Table
    static func selectResult(_ row: SQLite.Row) -> RepositoryItem
    static var col_id: SQLite.Expression<Int64> { get }
    static func itemSetters(_ item: RepositoryItem) -> [SQLite.Setter]

    var db: Connection? { get }
}

extension RepositoryProtocol {
    func select(table: SQLite.Table = Self.table) -> [RepositoryItem] {
        guard let db else { return [] }
        do {
            var results: [RepositoryItem] = []
            for row in try db.prepare(Self.selectQuery(from: table)) {
                results.append(Self.selectResult(row))
            }
            print("Successfully loaded from \(Self.repositoryName): \(results.count)")
            return results
        } catch {
            print("Error loading from \(Self.repositoryName): \(error)")
            return []
        }
    }

    func insert(_ item: inout RepositoryItem) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.table.insert(Self.itemSetters(item))
            let rowid = try db.run(query)
            item.id = rowid
            print("Successfully added \(RepositoryItem.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed to add \(RepositoryItem.modelName): \(error)")
            return false
        }
    }

    func update(_ item: RepositoryItem) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.table.filter(Self.col_id == item.id).update(Self.itemSetters(item))
            try db.run(query)
            print("Successfully updated \(RepositoryItem.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed to update \(RepositoryItem.modelName): \(error)")
            return false
        }
    }

    func delete(_ item: RepositoryItem) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.table.filter(Self.col_id == item.id).delete()
            try db.run(query)
            print("Successfully deleted \(RepositoryItem.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed to delete \(RepositoryItem.modelName): \(error)")
            return false
        }
    }
}
