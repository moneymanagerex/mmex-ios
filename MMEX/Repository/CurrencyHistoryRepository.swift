//
//  CurrencyHistoryRepository.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct CurrencyHistoryRepository: RepositoryProtocol {
    typealias RepositoryData = CurrencyHistoryData

    let db: Connection

    static let repositoryName = "CURRENCYHISTORY_V1"
    static let table = SQLite.Table(repositoryName)

    // column      | type    | other
    // ------------+---------+------
    // CURRHISTID  | INTEGER | PRIMARY KEY
    // CURRENCYID  | INTEGER | NOT NULL
    // CURRDATE    | TEXT    | NOT NULL (yyyy-MM-dd)
    // CURRVALUE   | NUMERIC | NOT NULL
    // CURRUPDTYPE | INTEGER |
    //             |         | UNIQUE(CURRENCYID, CURRDATE)

    // column expressions
    static let col_id          = SQLite.Expression<Int64>("CURRHISTID")
    static let col_currencyId  = SQLite.Expression<Int64>("CURRENCYID")
    static let col_currDate    = SQLite.Expression<String>("CURRDATE")
    static let col_currValue   = SQLite.Expression<Double>("CURRVALUE")
    static let col_currUpdType = SQLite.Expression<Int?>("CURRUPDTYPE")

    // cast NUMERIC to REAL
    static let cast_currValue = cast(col_currValue) as SQLite.Expression<Double>

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_currencyId,
            col_currDate,
            cast_currValue,
            col_currUpdType
        )
    }

    static func fetchData(_ row: SQLite.Row) -> CurrencyHistoryData {
        return CurrencyHistoryData(
            id           : DataId(row[col_id]),
            currencyId   : DataId(row[col_currencyId]),
            date         : DateString(row[col_currDate]),
            baseConvRate : row[cast_currValue],
            updateType   : UpdateType(rawValue: row[col_currUpdType] ?? -1)
        )
    }

    static func itemSetters(_ data: CurrencyHistoryData) -> [SQLite.Setter] {
        return [
            col_currencyId  <- Int64(data.currencyId),
            col_currDate    <- data.date.string,
            col_currValue   <- data.baseConvRate,
            col_currUpdType <- data.updateType?.rawValue
        ]
    }
}

extension CurrencyHistoryRepository {
    func delete(currencyId: DataId) -> Bool {
        do {
            let query = Self.table
                .filter(Self.col_currencyId == Int64(currencyId))
                .delete()
            log.trace("DEBUG: CurrencyHistoryRepository.delete(main=\(Thread.isMainThread)): \(query.expression.description)")
            try db.run(query)
            log.info("INFO: CurrencyHistoryRepository.delete(\(Self.repositoryName))")
            return true
        } catch {
            log.error("ERROR: CurrencyHistoryRepository.delete(\(Self.repositoryName)): \(error)")
            return false
        }
    }
}
