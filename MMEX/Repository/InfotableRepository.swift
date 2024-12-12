//
//  InfotableRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

struct InfotableRepository: RepositoryProtocol {
    typealias RepositoryData = InfotableData

    let db: Connection
    let databaseName: String

    static let repositoryName = "INFOTABLE_V1"
    static let table = SQLite.Table(repositoryName)

    // column    | type    | other
    // ----------+---------+------
    // INFOID    | INTEGER | NOT NULL PRIMARY KEY
    // INFONAME  | TEXT    | NOT NULL UNIQUE COLLATE NOCASE
    // INFOVALUE | TEXT    | NOT NULL

    // column expressions
    static let col_id    = SQLite.Expression<Int64>("INFOID")
    static let col_name  = SQLite.Expression<String>("INFONAME")
    static let col_value = SQLite.Expression<String>("INFOVALUE")

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_value
        )
    }

    static func fetchData(_ row: SQLite.Row) -> InfotableData {
        return InfotableData(
            id    : DataId(row[col_id]),
            name  : row[col_name],
            value : row[col_value]
        )
    }

    static func itemSetters(_ data: InfotableData) -> [SQLite.Setter] {
        return [
            col_name  <- data.name,
            col_value <- data.value
        ]
    }
}

extension InfotableRepository {
    // load all keys
    func load() -> [InfotableData]? {
        log.trace("DEBUG: InfotableRepository.load()")
        return select(from: Self.table)
    }

    // load specific keys into a dictionary
    func load(for keys: [InfoKey]) -> [InfoKey: InfotableData] {
        log.trace("DEBUG: InfotableRepository.load(for:)")
        var results: [InfoKey: InfotableData] = [:]
        for key in keys {
            let info: InfotableData? = pluck(
                key: key.rawValue,
                from: Self.table.filter(Self.col_name == key.rawValue)
            ).toOptional()
            if let info { results[key] = info }
        }
        return results
    }

    // Fetch value for a specific key, allowing for String or Int64
    // nil result indicates an error or absence of key
    func getValue<T: LosslessStringConvertible>(for key: String, as type: T.Type) -> T? {
        log.trace("DEBUG: InfotableRepository.getValue(for: \(key))")
        let info: InfotableData? = pluck(
            key: key,
            from: Self.table.filter(Self.col_name == key)
        ).toOptional()
        return if let info { info.getValue(as: T.self) } else { nil }
    }

    // nil result indicates an error; defaultValue is returned if key is absent
    func getValue<T: LosslessStringConvertible>(for key: String, default defaultValue: T) -> T? {
        log.trace("DEBUG: InfotableRepository.getValue(for: \(key), default:)")
        let info: RepositoryPluckResult<InfotableData> = pluck(
            key: key,
            from: Self.table.filter(Self.col_name == key)
        )
        return switch info {
        case .some(let info): info.getValue(as: T.self)
        case .none: defaultValue
        default: nil
        }
    }

    // Update or insert a setting with support for String or Int64 values
    func setValue<T: LosslessStringConvertible>(_ value: T, for key: String) -> Bool {
        log.trace("DEBUG: InfotableRepository.setValue(for: \(key))")
        let valueDescription: String = value.description
        let info: RepositoryPluckResult<InfotableData> = pluck(
            key: key,
            from: Self.table.filter(Self.col_name == key)
        )
        switch info {
        case .some(var info):
            // Update existing setting
            info.value = valueDescription
            return update(info)
        case .none:
            // Insert new setting
            var info = InfotableData(id: 0, name: key, value: valueDescription)
            return insert(&info)
        default:
            return false
        }
    }
}
