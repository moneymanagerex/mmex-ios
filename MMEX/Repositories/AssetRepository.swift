//
//  AssetRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class AssetRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }
}

extension AssetRepository {
    // table query
    static let table = SQLite.Table("ASSETS_V1")

    // column          | type    | other
    // ----------------+---------+------
    // ASSETID         | INTEGER | PRIMARY KEY
    // ASSETTYPE       | TEXT    | (Property, Automobile, ...)
    // ASSETSTATUS     | TEXT    | (Closed, Open)
    // ASSETNAME       | TEXT    | NOT NULL COLLATE NOCASE
    // STARTDATE       | TEXT    | NOT NULL
    // CURRENCYID      | INTEGER |
    // VALUE           | NUMERIC |
    // VALUECHANGE     | TEXT    | (None, Appreciates, Depreciates)
    // VALUECHANGEMODE | TEXT    | (Percentage, Linear)
    // VALUECHANGERATE | NUMERIC |
    // NOTES           | TEXT    |

    // table columns
    static let col_id         = SQLite.Expression<Int64>("ASSETID")
    static let col_type       = SQLite.Expression<String?>("ASSETTYPE")
    static let col_status     = SQLite.Expression<String?>("ASSETSTATUS")
    static let col_name       = SQLite.Expression<String>("ASSETNAME")
    static let col_startDate  = SQLite.Expression<String>("STARTDATE")
    static let col_currencyId = SQLite.Expression<Int64?>("CURRENCYID")
    static let col_value      = SQLite.Expression<Double?>("VALUE")
    static let col_change     = SQLite.Expression<String?>("VALUECHANGE")
    static let col_changeMode = SQLite.Expression<String?>("VALUECHANGEMODE")
    static let col_changeRate = SQLite.Expression<Double?>("VALUECHANGERATE")
    static let col_notes      = SQLite.Expression<String?>("NOTES")

    // cast NUMERIC to REAL
    static let cast_value      = cast(col_value)      as SQLite.Expression<Double?>
    static let cast_changeRate = cast(col_changeRate) as SQLite.Expression<Double?>
}

extension AssetRepository {
    // select query
    static let selectQuery = table.select(
        col_id,
        col_type,
        col_status,
        col_name,
        col_startDate,
        col_currencyId,
        cast_value,
        col_change,
        col_changeMode,
        cast_changeRate,
        col_notes
    )

    // select result
    static func selectResult(_ row: Row) -> Asset {
        return Asset(
            id         : row[col_id],
            type       : AssetType(collateNoCase: row[col_type]),
            status     : AssetStatus(collateNoCase: row[col_status]),
            name       : row[col_name],
            startDate  : row[col_startDate],
            currencyId : row[col_currencyId],
            value      : row[cast_value],
            change     : AssetChange(collateNoCase: row[col_change]),
            changeMode : AssetChangeMode(collateNoCase: row[col_changeMode]),
            changeRate : row[cast_changeRate],
            notes      : row[col_notes]
        )
    }

    static func insertSetters(_ asset: Asset) -> [Setter] {
        return [
            col_id         <- asset.id,
            col_type       <- asset.type.map { $0.name },
            col_status     <- asset.status.map { $0.name },
            col_name       <- asset.name,
            col_startDate  <- asset.startDate,
            col_currencyId <- asset.currencyId,
            col_value      <- asset.value,
            col_change     <- asset.change.map { $0.name },
            col_changeMode <- asset.changeMode.map { $0.name },
            col_changeRate <- asset.changeRate,
            col_notes      <- asset.notes
        ]
    }

    // insert query
    static func insertQuery(_ asset: Asset) -> SQLite.Insert {
        return table.insert(insertSetters(asset))
    }

    // update query
    static func updateQuery(_ asset: Asset) -> SQLite.Update {
        return table.filter(col_id == asset.id).update(insertSetters(asset))
    }

    // delete query
    static func deleteQuery(_ asset: Asset) -> SQLite.Delete {
        return table.filter(col_id == asset.id).delete()
    }
}

extension AssetRepository {
    func loadAssets() -> [Asset] {
        guard let db else { return [] }
        do {
            var assets: [Asset] = []
            for row in try db.prepare(AssetRepository.selectQuery
                .order(AssetRepository.col_type, AssetRepository.col_status.desc, AssetRepository.col_name)
            ) {
                assets.append(AssetRepository.selectResult(row))
            }
            print("Successfully loaded assets: \(assets.count)")
            return assets
        } catch {
            print("Error loading assets: \(error)")
            return []
        }
    }

    func addAsset(asset: inout Asset) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(AssetRepository.insertQuery(asset))
            asset.id = rowid
            print("Successfully added asset: \(asset.name), \(asset.id)")
            return true
        } catch {
            print("Failed to add asset: \(error)")
            return false
        }
    }

    func updateAsset(asset: Asset) -> Bool {
        guard let db else { return false }
        do {
            try db.run(AssetRepository.updateQuery(asset))
            print("Successfully updated asset: \(asset.name), \(asset.id)")
            return true
        } catch {
            print("Failed to update asset: \(error)")
            return false
        }
    }

    func deleteAsset(asset: Asset) -> Bool {
        guard let db else { return false }
        do {
            try db.run(AssetRepository.deleteQuery(asset))
            print("Successfully deleted asset: \(asset.name), \(asset.id)")
            return true
        } catch {
            print("Failed to delete asset: \(error)")
            return false
        }
    }
}
