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

    var db: Connection? { get }

    static var repositoryName: String { get }
    static var repositoryTable: SQLite.Table { get }
    static func selectQuery(from table: SQLite.Table) -> SQLite.Table
    static func selectResult(_ row: SQLite.Row) -> RepositoryItem
    static var col_id: SQLite.Expression<Int64> { get }
    static func itemSetters(_ item: RepositoryItem) -> [SQLite.Setter]
}

extension RepositoryProtocol {
    func pluck(table: SQLite.Table, key: String) -> RepositoryItem? {
        guard let db else { return nil }
        do {
            if let row = try db.pluck(Self.selectQuery(from: table)) {
                let item = Self.selectResult(row)
                print("Successfull search for \(key) in \(Self.repositoryName): \(item.shortDesc())")
                return item
            }
            else {
                print("Unsuccefull search for \(key) in \(Self.repositoryName)")
                return nil
            }
        } catch {
            print("Failed search for \(key) in \(Self.repositoryName): \(error)")
            return nil
        }
    }

    func select(table: SQLite.Table) -> [RepositoryItem] {
        guard let db else { return [] }
        do {
            var results: [RepositoryItem] = []
            for row in try db.prepare(Self.selectQuery(from: table)) {
                results.append(Self.selectResult(row))
            }
            print("Successfull select in \(Self.repositoryName): \(results.count)")
            return results
        } catch {
            print("Failed select in \(Self.repositoryName): \(error)")
            return []
        }
    }

    func insert(_ item: inout RepositoryItem) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.repositoryTable
                .insert(Self.itemSetters(item))
            let rowid = try db.run(query)
            item.id = rowid
            print("Successfull insert in \(RepositoryItem.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed insert in \(RepositoryItem.modelName): \(error)")
            return false
        }
    }

    func update(_ item: RepositoryItem) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.repositoryTable
                .filter(Self.col_id == item.id)
                .update(Self.itemSetters(item))
            try db.run(query)
            print("Successfull update in \(RepositoryItem.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed update in \(RepositoryItem.modelName): \(error)")
            return false
        }
    }

    func delete(_ item: RepositoryItem) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.repositoryTable
                .filter(Self.col_id == item.id)
                .delete()
            try db.run(query)
            print("Successfull delete in \(RepositoryItem.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed delete in \(RepositoryItem.modelName): \(error)")
            return false
        }
    }
}
