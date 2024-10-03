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

    var db: Connection { get }

    static var repositoryName: String { get }
    static var table: SQLite.Table { get }
    static func selectData(from table: SQLite.Table) -> SQLite.Table
    static func fetchData(_ row: SQLite.Row) -> RepositoryData
    static var col_id: SQLite.Expression<Int64> { get }
    static func itemSetters(_ item: RepositoryData) -> [SQLite.Setter]
}

extension RepositoryProtocol {
    func pluck<Result>(
        key: String,
        from table: SQLite.Table,
        with result: (SQLite.Row) -> Result = Self.fetchData
    ) -> Result? {
        do {
            let query = Self.selectData(from: table)
            log.trace("RepositoryProtocol.pluck(): \(query.expression.description)")
            if let row = try db.pluck(query) {
                let data = result(row)
                log.info("Successfull pluck of \(key) from \(Self.repositoryName)")
                return data
            } else {
                log.info("Unsuccefull pluck of \(key) from \(Self.repositoryName)")
                return nil
            }
        } catch {
            log.error("Failed pluck of \(key) from \(Self.repositoryName): \(error)")
            return nil
        }
    }

    func pluck<Result>(
        id: Int64,
        with result: (SQLite.Row) -> Result = Self.fetchData
    ) -> Result? {
        pluck(
            key: "id \(id)",
            from: Self.table.filter(Self.col_id == id),
            with: result
        )
    }

    func select<Result>(
        from table: SQLite.Table,
        with result: (SQLite.Row) -> Result = Self.fetchData
    ) -> [Result] {
        do {
            var data: [Result] = []
            let query = Self.selectData(from: table)
            log.trace("RepositoryProtocol.select(): \(query.expression.description)")
            for row in try db.prepare(query) {
                data.append(result(row))
            }
            log.info("Successfull select from \(Self.repositoryName): \(data.count)")
            return data
        } catch {
            log.error("Failed select from \(Self.repositoryName): \(error)")
            return []
        }
    }

    func dict<Result>(
        from table: SQLite.Table = Self.table,
        with result: (SQLite.Row) -> Result = Self.fetchData
    ) -> [Int64: Result] {
        do {
            var dict: [Int64: Result] = [:]
            let query = Self.selectData(from: table)
            log.trace("RepositoryProtocol.dict(): \(query.expression.description)")
            for row in try db.prepare(query) {
                dict[row[Self.col_id]] = result(row)
            }
            log.info("Successfull dictionary from \(Self.repositoryName): \(dict.count)")
            return dict
        } catch {
            log.error("Failed dictionary from \(Self.repositoryName): \(error)")
            return [:]
        }
    }

    func insert(_ data: inout RepositoryData) -> Bool {
        do {
            let query = Self.table
                .insert(Self.itemSetters(data))
            log.trace("RepositoryProtocol.insert(): \(query.expression.description)")
            let rowid = try db.run(query)
            data.id = rowid
            log.info("Successfull insert in \(RepositoryData.dataName)")
            return true
        } catch {
            log.error("Failed insert in \(RepositoryData.dataName): \(error)")
            return false
        }
    }

    func update(_ data: RepositoryData) -> Bool {
        guard data.id > 0 else { return false }
        do {
            let query = Self.table
                .filter(Self.col_id == data.id)
                .update(Self.itemSetters(data))
            log.trace("RepositoryProtocol.update(): \(query.expression.description)")
            try db.run(query)
            log.info("Successfull update in \(RepositoryData.dataName): \(data.shortDesc())")
            return true
        } catch {
            log.error("Failed update in \(RepositoryData.dataName): \(error)")
            return false
        }
    }

    func delete(_ data: RepositoryData) -> Bool {
        guard data.id > 0 else { return false }
        do {
            let query = Self.table
                .filter(Self.col_id == data.id)
                .delete()
            log.trace("RepositoryProtocol.delete(): \(query.expression.description)")
            try db.run(query)
            log.info("Successfull delete in \(RepositoryData.dataName): \(data.shortDesc())")
            return true
        } catch {
            log.error("Failed delete in \(RepositoryData.dataName): \(error)")
            return false
        }
    }

    func deleteAll() -> Bool {
        do {
            let query = Self.table.delete()
            log.trace("RepositoryProtocol.deleteAll(): \(query.expression.description)")
            try db.run(query)
            log.info("Successfull delete all in \(RepositoryData.dataName)")
            return true
        } catch {
            log.error("Failed delete all in \(RepositoryData.dataName): \(error)")
            return false
        }
    }
}

/*
extension RepositoryProtocol {
    func create() {
        var query: String = "CREATE TABLE \(Self.repositoryName)("
        var comma = false
        for (name, type, other) in Self.columns {
            if comma { query.append(", ") }
            var space = false
            if !name.isEmpty {
                query.append("\(name) \(type)")
                space = true
            }
            if !other.isEmpty {
                if space { query.append(" ") }
                query.append("\(other)")
            }
            comma = true
        }
        query.append(")")
        log.trace("Executing query: \(query)")
        do {
            try db.execute(query)
        } catch {
            log.error("Failed to create table \(Self.repositoryName): \(error)")
        }
    }
*/
