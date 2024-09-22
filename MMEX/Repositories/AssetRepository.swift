//
//  AssetRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class AssetRepository: RepositoryProtocol {
    typealias RepositoryItem = Asset

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "ASSETS_V1"
    static let repositoryTable = SQLite.Table(repositoryName)

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
    
    // columns
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

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
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
    }

    static func selectResult(_ row: SQLite.Row) -> Asset {
        return Asset(
            id         : row[col_id],
            type       : AssetType(collateNoCase: row[col_type]) ?? AssetType.property,
            status     : AssetStatus(collateNoCase: row[col_status]) ?? AssetStatus.open,
            name       : row[col_name],
            startDate  : row[col_startDate],
            currencyId : row[col_currencyId] ?? 0,
            value      : row[cast_value] ?? 0.0,
            change     : AssetChange(collateNoCase: row[col_change]) ?? AssetChange.none,
            changeMode : AssetChangeMode(collateNoCase: row[col_changeMode]) ?? AssetChangeMode.percentage,
            changeRate : row[cast_changeRate] ?? 0.0,
            notes      : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ asset: Asset) -> [SQLite.Setter] {
        return [
            col_id         <- asset.id,
            col_type       <- asset.type.name,
            col_status     <- asset.status.name,
            col_name       <- asset.name,
            col_startDate  <- asset.startDate,
            col_currencyId <- asset.currencyId,
            col_value      <- asset.value,
            col_change     <- asset.change.name,
            col_changeMode <- asset.changeMode.name,
            col_changeRate <- asset.changeRate,
            col_notes      <- asset.notes
        ]
    }
}

extension AssetRepository {
    func load() -> [Asset] { select(table: Self.repositoryTable
        .order(Self.col_type, Self.col_status.desc, Self.col_name)
    ) }
}
