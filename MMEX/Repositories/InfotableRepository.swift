//
//  InfotableRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

class InfotableRepository: RepositoryProtocol {
    typealias RepositoryItem = Infotable

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "INFOTABLE_V1"
    static let repositoryTable = SQLite.Table(repositoryName)

    // column    | type    | other
    // ----------+---------+------
    // INFOID    | INTEGER | NOT NULL PRIMARY KEY
    // INFONAME  | TEXT    | NOT NULL UNIQUE COLLATE NOCASE
    // INFOVALUE | TEXT    | NOT NULL

    // columns
    static let col_id    = SQLite.Expression<Int64>("INFOID")
    static let col_name  = SQLite.Expression<String>("INFONAME")
    static let col_value = SQLite.Expression<String>("INFOVALUE")

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_value
        )
    }

    static func selectResult(_ row: SQLite.Row) -> Infotable {
        return Infotable(
            id    : row[col_id],
            name  : row[col_name],
            value : row[col_value]
        )
    }

    static func itemSetters(_ info: Infotable) -> [SQLite.Setter] {
        return [
            col_name  <- info.name,
            col_value <- info.value
        ]
    }
}

extension InfotableRepository {
    // load all keys
    func load() -> [Infotable] {
        return select(table: Self.repositoryTable)
    }

    // load specific keys into a dictionary
    func load(for keys: [InfoKey]) -> [InfoKey: Infotable] {
        if db == nil { return [:] }
        var results: [InfoKey: Infotable] = [:]
        for key in keys {
            if let info = pluck(
                table: Self.repositoryTable
                    .filter(Self.col_name == key.rawValue),
                key: key.rawValue
            ) {
                results[key] = info
            }
        }
        return results
    }

    // New Methods for Key-Value Pairs
    // Fetch value for a specific key, allowing for String or Int64
    func getValue<T>(for key: String, as type: T.Type) -> T? {
        if db == nil { return nil }
        if let info = pluck(
            table: Self.repositoryTable
                .filter(Self.col_name == key),
            key: key
        ) {
            if type == String.self {
                return info.value as? T
            } else if type == Int64.self {
                return Int64(info.value) as? T
            }
        }
        return nil
    }

    // Update or insert a setting with support for String or Int64 values
    func setValue<T>(_ value: T, for key: String) {
        if db == nil { return }

        var stringValue: String
        if let stringVal = value as? String {
            stringValue = stringVal
        } else if let intVal = value as? Int64 {
            stringValue = String(intVal)
        } else {
            print("Unsupported type for value: \(value)")
            return
        }

        if var info = pluck(
            table: Self.repositoryTable.filter(Self.col_name == key),
            key: key
        ) {
            // Update existing setting
            info.value = stringValue
            _ = update(info)
        } else {
            // Insert new setting
            var info = Infotable(id: 0, name: key, value: stringValue)
            _ = insert(&info)
        }
    }
}
