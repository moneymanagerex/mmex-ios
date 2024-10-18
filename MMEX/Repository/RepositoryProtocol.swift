//
//  RepositoryProtocaol.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum RepositoryError: Error {
    case repositoryError
}

enum RepositoryPluckResult<Wrapped: ~Copyable>: ~Copyable {
    case some(Wrapped)
    case none
    case error(RepositoryError)
}

extension RepositoryPluckResult: Copyable where Wrapped: Copyable {
}

extension RepositoryPluckResult {
    init(_ optValue: Optional<Wrapped>) {
       self = switch optValue {
       case .some(let value): .some(value)
       default: .none
       }
    }

    func toOptional() -> Optional<Wrapped> {
        return switch self {
        case .some(let value): .some(value)
        default: .none
        }
    }
}

protocol RepositoryProtocol {
    associatedtype RepositoryData: DataProtocol

    var db: Connection { get }
    init(db: Connection)

    static var repositoryName: String { get }
    static var table: SQLite.Table { get }
    static func selectData(from table: SQLite.Table) -> SQLite.Table
    static func fetchData(_ row: SQLite.Row) -> RepositoryData
    static func fetchId(_ row: SQLite.Row) -> DataId
    static var col_id: SQLite.Expression<Int64> { get }
    static func itemSetters(_ item: RepositoryData) -> [SQLite.Setter]
}

extension RepositoryProtocol {
    init(_ db: Connection) {
        self.init(db: db)
    }

    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.init(db: db)
    }
}

extension RepositoryProtocol {
    static func fetchId(_ row: SQLite.Row) -> DataId { DataId(row[Self.col_id]) }
}

extension RepositoryProtocol {
    func pluck<DataValue>(
        key: String,
        from table: SQLite.Table,
        with value: (SQLite.Row) -> DataValue = Self.fetchData
    ) -> RepositoryPluckResult<DataValue> {
        do {
            let query = Self.selectData(from: table)
            log.trace("DEBUG: RepositoryProtocol.pluck(): \(query.expression.description)")
            if let row = try db.pluck(query) {
                let dataValue = value(row)
                log.info("INFO: RepositoryProtocol.pluck(\(Self.repositoryName), \(key)): found")
                return .some(dataValue)
            } else {
                log.info("INFO: RepositoryProtocol.pluck(\(Self.repositoryName), \(key)): not found")
                return .none
            }
        } catch {
            log.error("ERROR: RepositoryProtocol.pluck(\(Self.repositoryName), \(key)): \(error)")
            return .error(.repositoryError)
        }
    }

    func pluck<DataValue>(
        id: DataId,
        with value: (SQLite.Row) -> DataValue = Self.fetchData
    ) -> RepositoryPluckResult<DataValue> {
        pluck(
            key: "id \(id)",
            from: Self.table.filter(Self.col_id == Int64(id)),
            with: value
        )
    }

    func select<DataValue>(
        from table: SQLite.Table,
        with value: (SQLite.Row) -> DataValue = Self.fetchData
    ) -> [DataValue]? {
        do {
            var data: [DataValue] = []
            let query = Self.selectData(from: table)
            log.trace("DEBUG: RepositoryProtocol.select(): \(query.expression.description)")
            for row in try db.prepare(query) {
                data.append(value(row))
            }
            log.info("INFO: RepositoryProtocol.select(\(Self.repositoryName)): \(data.count)")
            return data
        } catch {
            log.error("ERROR: RepositoryProtocol.select(\(Self.repositoryName)): \(error)")
            return nil
        }
    }

    func selectId(
        from table: SQLite.Table
    ) -> [DataId]? {
        do {
            var dataId: [DataId] = []
            let query = table.select(Self.col_id)
            log.trace("DEBUG: RepositoryProtocol.selectId(): \(query.expression.description)")
            for row in try db.prepare(query) {
                dataId.append(Self.fetchId(row))
            }
            log.info("INFO: RepositoryProtocol.selectId(\(Self.repositoryName)): \(dataId.count)")
            return dataId
        } catch {
            log.error("ERROR: RepositoryProtocol.selectId(\(Self.repositoryName)): \(error)")
            return nil
        }
    }

    func selectById<DataValue>(
        from table: SQLite.Table = Self.table,
        with value: (SQLite.Row) -> DataValue = Self.fetchData
    ) -> [DataId: DataValue]? {
        do {
            var dict: [DataId: DataValue] = [:]
            let query = Self.selectData(from: table)
            log.trace("DEBUG: RepositoryProtocol.selectById(): \(query.expression.description)")
            for row in try db.prepare(query) {
                let id = Self.fetchId(row)
                dict[id] = value(row)
            }
            log.info("INFO: RepositoryProtocol.selectById(\(Self.repositoryName)): \(dict.count)")
            return dict
        } catch {
            log.error("ERROR: RepositoryProtocol.selectById(\(Self.repositoryName)): \(error)")
            return nil
        }
    }

    func selectBy<DataProperty, DataValue>(
        property: (SQLite.Row) -> DataProperty,
        from table: SQLite.Table = Self.table,
        with value: (SQLite.Row) -> DataValue = Self.fetchData
    ) -> [DataProperty: [DataValue]]? {
        do {
            var dataByProperty: [DataProperty: [DataValue]] = [:]
            let query = Self.selectData(from: table)
            log.trace("DEBUG: RepositoryProtocol.selectBy(): \(query.expression.description)")
            for row in try db.prepare(query) {
                let i = property(row)
                if dataByProperty[i] == nil { dataByProperty[i] = [] }
                dataByProperty[i]!.append(value(row))
            }
            log.info("INFO: RepositoryProtocol.selectBy(): \(dataByProperty.count)")
            return dataByProperty
        } catch {
            log.error("ERROR: RepositoryProtocol.selectBy(): \(error)")
            return nil
        }
    }

    func insert(_ data: inout RepositoryData) -> Bool {
        do {
            let query = Self.table
                .insert(Self.itemSetters(data))
            log.trace("DEBUG: RepositoryProtocol.insert(): \(query.expression.description)")
            let rowid = try db.run(query)
            data.id = DataId(rowid)
            let desc = data.shortDesc()
            log.info("INFO: RepositoryProtocol.insert(\(Self.repositoryName)): \(desc)")
            return true
        } catch {
            log.error("ERROR: RepositoryProtocol.insert\(Self.repositoryName)): \(error)")
            return false
        }
    }

    func update(_ data: RepositoryData) -> Bool {
        guard data.id > 0 else { return false }
        do {
            let query = Self.table
                .filter(Self.col_id == Int64(data.id))
                .update(Self.itemSetters(data))
            log.trace("DEBUG: RepositoryProtocol.update(): \(query.expression.description)")
            try db.run(query)
            log.info("INFO: RepositoryProtocol.update(\(Self.repositoryName)): \(data.shortDesc())")
            return true
        } catch {
            log.error("ERROR: RepositoryProtocol.update(\(Self.repositoryName)): \(error)")
            return false
        }
    }

    func delete(_ data: RepositoryData) -> Bool {
        guard data.id > 0 else { return false }
        do {
            let query = Self.table
                .filter(Self.col_id == Int64(data.id))
                .delete()
            log.trace("DEBUG: RepositoryProtocol.delete(): \(query.expression.description)")
            try db.run(query)
            log.info("INFO: RepositoryProtocol.delete(\(Self.repositoryName)): \(data.shortDesc())")
            return true
        } catch {
            log.error("ERROR: RepositoryProtocol.delete(\(Self.repositoryName)): \(error)")
            return false
        }
    }

    func deleteAll() -> Bool {
        do {
            let query = Self.table.delete()
            log.trace("DEBUG: RepositoryProtocol.deleteAll(): \(query.expression.description)")
            try db.run(query)
            log.info("INFO: RepositoryProtocol.deleteAll(\(Self.repositoryName))")
            return true
        } catch {
            log.error("ERROR: RepositoryProtocol.deleteAll(\(Self.repositoryName)): \(error)")
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
        log.trace("DEBUG: RepositoryProtocol.create(): \(query)")
        do {
            try db.execute(query)
        } catch {
            log.error("ERROR: RepositoryProtocol.create(\(Self.repositoryName)): \(error)")
        }
    }
*/
