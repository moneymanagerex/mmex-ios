//
//  RepositoryProtocaol.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

protocol RepositoryProtocol {
    associatedtype RepositoryData: DataProtocol
    associatedtype RepositoryFull: FullProtocol

    var db: Connection? { get }

    static var repositoryName: String { get }
    static var repositoryTable: SQLite.Table { get }
    static func selectQuery(from table: SQLite.Table) -> SQLite.Table
    static func selectData(_ row: SQLite.Row) -> RepositoryData
    func selectFull(_ row: SQLite.Row) -> RepositoryFull
    static var col_id: SQLite.Expression<Int64> { get }
    static func itemSetters(_ item: RepositoryData) -> [SQLite.Setter]
}

extension RepositoryProtocol {
    func pluckData(table: SQLite.Table, key: String) -> RepositoryData? {
        guard let db else { return nil }
        do {
            if let row = try db.pluck(Self.selectQuery(from: table)) {
                let item = Self.selectData(row)
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

    func selectData(from table: SQLite.Table) -> [RepositoryData] {
        guard let db else { return [] }
        do {
            var results: [RepositoryData] = []
            for row in try db.prepare(Self.selectQuery(from: table)) {
                results.append(Self.selectData(row))
            }
            print("Successfull selectData from \(Self.repositoryName): \(results.count)")
            return results
        } catch {
            print("Failed selectData from \(Self.repositoryName): \(error)")
            return []
        }
    }

    func selectFull(from table: SQLite.Table) -> [RepositoryFull] {
        guard let db else { return [] }
        do {
            var cache: [RepositoryFull] = []
            for row in try db.prepare(Self.selectQuery(from: table)) {
                cache.append(selectFull(row))
            }
            print("Successfull selectFull from \(Self.repositoryName): \(cache.count)")
            return cache
        } catch {
            print("Failed selectFull from \(Self.repositoryName): \(error)")
            return []
        }
    }

    func insert(_ item: inout RepositoryData) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.repositoryTable
                .insert(Self.itemSetters(item))
            let rowid = try db.run(query)
            item.id = rowid
            print("Successfull insert in \(RepositoryData.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed insert in \(RepositoryData.modelName): \(error)")
            return false
        }
    }

    func update(_ item: RepositoryData) -> Bool {
        guard let db else { return false }
        guard item.id > 0 else { return false }
        do {
            let query = Self.repositoryTable
                .filter(Self.col_id == item.id)
                .update(Self.itemSetters(item))
            try db.run(query)
            print("Successfull update in \(RepositoryData.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed update in \(RepositoryData.modelName): \(error)")
            return false
        }
    }

    func delete(_ item: RepositoryData) -> Bool {
        guard let db else { return false }
        guard item.id > 0 else { return false }
        do {
            let query = Self.repositoryTable
                .filter(Self.col_id == item.id)
                .delete()
            try db.run(query)
            print("Successfull delete in \(RepositoryData.modelName): \(item.shortDesc())")
            return true
        } catch {
            print("Failed delete in \(RepositoryData.modelName): \(error)")
            return false
        }
    }
}
