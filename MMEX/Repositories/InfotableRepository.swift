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

    // Load specific keys into a dictionary
    func loadInfo(for keys: [InfoKey]) -> [InfoKey: Infotable] {
        var results: [InfoKey: Infotable] = [:]
        guard let db = db else { return results }

        do {
            for key in keys {
                if let row = try db.pluck(Infotable.table.filter(Infotable.infoName == key.rawValue)) {
                    let info = Infotable(
                        id: row[Infotable.infoID],
                        name: row[Infotable.infoName],
                        value: row[Infotable.infoValue]
                    )
                    results[key] = info
                }
            }
        } catch {
            print("Error loading info: \(error)")
        }
        return results
    }

    func loadInfo() -> [Infotable] {
        var infoItems: [Infotable] = []
        guard let db = db else { return [] }

        do {
            for info in try db.prepare(Infotable.table) {
                infoItems.append(Infotable(
                    id: info[Infotable.infoID],
                    name: info[Infotable.infoName],
                    value: info[Infotable.infoValue]
                ))
            }
        } catch {
            print("Error loading infotable: \(error)")
        }
        return infoItems
    }

    func updateInfo(info: Infotable) -> Bool {
        let infoToUpdate = Infotable.table.filter(Infotable.infoID == info.id)
        do {
            try db?.run(infoToUpdate.update(
                Infotable.infoName <- info.name,
                Infotable.infoValue <- info.value
            ))
            return true
        } catch {
            print("Failed to update infotable: \(error)")
            return false
        }
    }

    func deleteInfo(info: Infotable) -> Bool {
        let infoToDelete = Infotable.table.filter(Infotable.infoID == info.id)
        do {
            try db?.run(infoToDelete.delete())
            return true
        } catch {
            print("Failed to delete infotable: \(error)")
            return false
        }
    }

    func addInfo(info: inout Infotable) -> Bool {
        do {
            let insert = Infotable.table.insert(
                Infotable.infoName <- info.name,
                Infotable.infoValue <- info.value
            )
            let rowid = try db?.run(insert)
            info.id = rowid!
            print("Successfully added infotable: \(info.name), \(info.id)")
            return true
        } catch {
            print("Failed to add infotable: \(error)")
            return false
        }
    }
}
