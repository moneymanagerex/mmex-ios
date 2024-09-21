//
//  InfoRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation
import SQLite

class InfoRepository {
    private let db: Connection

    init(db: Connection) {
        self.db = db
    }

    func createTable() throws {
        let infoTable = SQLite.Table("INFOTABLE_V1")

        let id    = SQLite.Expression<Int64>("ID")
        let name  = SQLite.Expression<String>("INFONAME")
        let value = SQLite.Expression<String>("INFOVALUE")
        
        try db.run(infoTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name, unique: true)
            t.column(value)
        })
    }

    func fetchInfo(by name: String) -> Info? {
        let infoTable = SQLite.Table("INFOTABLE_V1")
        let nameExp  = SQLite.Expression<String>("INFONAME")
        let valueExp = SQLite.Expression<String>("INFOVALUE")
        
        if let row = try? db.pluck(infoTable.filter(nameExp == name)) {
            let id = try row.get(SQLite.Expression<Int64>("ID"))
            let value = try row.get(valueExp)
            return Info(id: id, name: name, value: value)
        }
        return nil
    }

    func insertOrUpdate(info: Info) throws {
        let infoTable = SQLite.Table("INFOTABLE_V1")
        let nameExp  = SQLite.Expression<String>("INFONAME")
        let valueExp = SQLite.Expression<String>("INFOVALUE")

        if let existing = fetchInfo(by: info.name) {
            try db.run(infoTable.filter(nameExp == info.name).update(valueExp <- info.value))
        } else {
            try db.run(infoTable.insert(nameExp <- info.name, valueExp <- info.value))
        }
    }
}
