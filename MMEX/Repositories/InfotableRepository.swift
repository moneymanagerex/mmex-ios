//
//  InfotableRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

class InfotableRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }
}

extension InfotableRepository {
    // table query
    static let table = SQLite.Table("INFOTABLE_V1")

    // column    | type    | other
    // ----------+---------+------
    // INFOID    | INTEGER | NOT NULL PRIMARY KEY
    // INFONAME  | TEXT    | NOT NULL UNIQUE COLLATE NOCASE
    // INFOVALUE | TEXT    | NOT NUL

    // table columns
    static let col_id    = SQLite.Expression<Int64>("INFOID")
    static let col_name  = SQLite.Expression<String>("INFONAME")
    static let col_value = SQLite.Expression<String>("INFOVALUE")
}

extension InfotableRepository {
    // select query
    static let selectQuery = table.select(
        col_id,
        col_name,
        col_value
    )

    // select result
    static func selectResult(_ row: Row) -> Infotable {
        return Infotable(
            id    : row[col_id],
            name  : row[col_name],
            value : row[col_value]
        )
    }

    // insert query
    static func insertQuery(_ info: Infotable) -> SQLite.Insert {
        return table.insert(
            col_name  <- info.name,
            col_value <- info.value
        )
    }

    // update query
    static func updateQuery(_ info: Infotable) -> SQLite.Update {
        return table.filter(col_id == info.id).update(
            col_name  <- info.name,
            col_value <- info.value
        )
    }

    // delete query
    static func deleteQuery(_ info: Infotable) -> SQLite.Delete {
        return table.filter(col_id == info.id).delete()
    }
}

extension InfotableRepository {
    // load all keys
    func loadInfo() -> [Infotable] {
        guard let db else { return [] }
        do {
            var results: [Infotable] = []
            for row in try db.prepare(InfotableRepository.selectQuery) {
                results.append(InfotableRepository.selectResult(row))
            }
            print("Successfully loaded infotable: \(results.count)")
            return results
        } catch {
            print("Error loading infotable: \(error)")
            return []
        }
    }

    // load specific keys into a dictionary
    func loadInfo(for keys: [InfoKey]) -> [InfoKey: Infotable] {
        guard let db else { return [:] }
        do {
            var results: [InfoKey: Infotable] = [:]
            for key in keys {
                if let row = try db.pluck(InfotableRepository.selectQuery
                    .filter(InfotableRepository.col_name == key.rawValue)
                ) {
                    results[key] = InfotableRepository.selectResult(row)
                    print("Successfully loaded infokey: \(key.rawValue)")
                }
                else {
                    print("Unknown infokey: \(key.rawValue)")
                }
            }
            return results
        } catch {
            print("Error loading info: \(error)")
            return [:]
        }
    }

    func addInfo(info: inout Infotable) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(InfotableRepository.insertQuery(info))
            info.id = rowid
            print("Successfully added infokey: \(info.name), \(info.id)")
            return true
        } catch {
            print("Failed to add infotable: \(error)")
            return false
        }
    }

    func updateInfo(info: Infotable) -> Bool {
        guard let db else { return false }
        do {
            try db.run(InfotableRepository.updateQuery(info))
            print("Successfully updated infokey: \(info.name)")
            return true
        } catch {
            print("Failed to update info: \(error)")
            return false
        }
    }

    func deleteInfo(info: Infotable) -> Bool {
        guard let db else { return false }
        do {
            try db.run(InfotableRepository.deleteQuery(info))
            print("Successfully deleted infokey: \(info.name)")
            return true
        } catch {
            print("Failed to delete infokey: \(error)")
            return false
        }
    }

    // New Methods for Key-Value Pairs
    // Fetch value for a specific key, allowing for String or Int64
    func getValue<T>(for key: String, as type: T.Type) -> T? {
        guard let db else { return nil }
        do {
            if let row = try db.pluck(InfotableRepository.selectQuery
                .filter(InfotableRepository.col_name == key)
            ) {
                let value = row[InfotableRepository.col_value]
                if type == String.self {
                    return value as? T
                } else if type == Int64.self {
                    return Int64(value) as? T
                }
            }
        } catch {
            print("Error fetching value for key \(key): \(error)")
        }
        return nil
    }

    // Update or insert a setting with support for String or Int64 values
    func setValue<T>(_ value: T, for key: String) {
        guard let db else { return }

        var stringValue: String
        if let stringVal = value as? String {
            stringValue = stringVal
        } else if let intVal = value as? Int64 {
            stringValue = String(intVal)
        } else {
            print("Unsupported type for value: \(value)")
            return
        }

        let query = InfotableRepository.table.filter(InfotableRepository.col_name == key)
        do {
            if let _ = try db.pluck(query) {
                // Update existing setting
                try db.run(query.update(
                    InfotableRepository.col_value <- stringValue
                ) )
            } else {
                // Insert new setting
                try db.run(InfotableRepository.table.insert(
                    InfotableRepository.col_name  <- key,
                    InfotableRepository.col_value <- stringValue
                ) )
            }
        } catch {
            print("Error setting value for key \(key): \(error)")
        }
    }
}
