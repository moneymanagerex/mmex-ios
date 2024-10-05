//
//  AssetRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct AssetRepository: RepositoryProtocol {
    typealias RepositoryData = AssetData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "ASSETS_V1"
    static let table = SQLite.Table(repositoryName)

    // column          | type    | other
    // ----------------+---------+------
    // ASSETID         | INTEGER | PRIMARY KEY
    // ASSETTYPE       | TEXT    | (Property, Automobile, ...)
    // ASSETSTATUS     | TEXT    | (Closed, Open)
    // ASSETNAME       | TEXT    | NOT NULL COLLATE NOCASE
    // STARTDATE       | TEXT    | NOT NULL (yyyy-MM-dd)
    // CURRENCYID      | INTEGER |
    // VALUE           | NUMERIC |
    // VALUECHANGE     | TEXT    | (None, Appreciates, Depreciates)
    // VALUECHANGEMODE | TEXT    | (Percentage, Linear)
    // VALUECHANGERATE | NUMERIC |
    // NOTES           | TEXT    |

    // column expressions
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

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
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

    static func fetchData(_ row: SQLite.Row) -> AssetData {
        return AssetData(
            id         : row[col_id],
            type       : AssetType(collateNoCase: row[col_type]),
            status     : AssetStatus(collateNoCase: row[col_status]),
            name       : row[col_name],
            startDate  : DateString(row[col_startDate]),
            currencyId : row[col_currencyId] ?? 0,
            value      : row[cast_value] ?? 0.0,
            change     : AssetChange(collateNoCase: row[col_change]),
            changeMode : AssetChangeMode(collateNoCase: row[col_changeMode]),
            changeRate : row[cast_changeRate] ?? 0.0,
            notes      : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ data: AssetData) -> [SQLite.Setter] {
        return [
            col_type       <- data.type.name,
            col_status     <- data.status.name,
            col_name       <- data.name,
            col_startDate  <- data.startDate.string,
            col_currencyId <- data.currencyId,
            col_value      <- data.value,
            col_change     <- data.change.name,
            col_changeMode <- data.changeMode.name,
            col_changeRate <- data.changeRate,
            col_notes      <- data.notes
        ]
    }
}

extension AssetRepository {
    // load all assets
    func load() -> [AssetData] {
        return select(from: Self.table
            .order(Self.col_type, Self.col_status.desc, Self.col_name)
        )
    }

    // load assets by type
    func loadByType<Result>(
        from table: SQLite.Table = Self.table,
        with result: (SQLite.Row) -> Result = Self.fetchData
    ) -> [AssetType: [Result]] {
        do {
            var dataByType: [AssetType: [Result]] = [:]
            for row in try db.prepare(Self.selectData(from: table)) {
                let type = AssetType(collateNoCase: row[Self.col_type])
                if dataByType[type] == nil { dataByType[type] = [] }
                dataByType[type]!.append(result(row))
            }
            log.info("Successfull select from \(Self.repositoryName): \(dataByType.count)")
            return dataByType
        } catch {
            log.error("Failed select from \(Self.repositoryName): \(error)")
            return [:]
        }
    }

    // load currencyId for all accounts
    func loadCurrencyId() -> [Int64] {
        return Repository(db).select(from: Self.table
            .select(distinct: Self.col_currencyId)
        ) { row in
            row[Self.col_currencyId] ?? 0
        }
    }
}
