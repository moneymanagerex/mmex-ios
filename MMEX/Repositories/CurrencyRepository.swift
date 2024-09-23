//
//  CurrencyRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SQLite

class CurrencyRepository: RepositoryProtocol {
    typealias RepositoryData = CurrencyData
    typealias RepositoryFull = CurrencyFull

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "CURRENCYFORMATS_V1"
    static let repositoryTable = SQLite.Table(repositoryName)

    // column          | type    | other
    // ----------------+---------+------
    // CURRENCYID      | INTEGER | PRIMARY KEY
    // CURRENCYNAME    | TEXT    | NOT NULL COLLATE NOCASE UNIQUE
    // PFX_SYMBOL      | TEXT    |
    // SFX_SYMBOL      | TEXT    |
    // DECIMAL_POINT   | TEXT    |
    // GROUP_SEPARATOR | TEXT    |
    // UNIT_NAME       | TEXT    | COLLATE NOCASE
    // CENT_NAME       | TEXT    | COLLATE NOCASE
    // SCALE           | INTEGER |
    // BASECONVRATE    | NUMERIC |
    // CURRENCY_SYMBOL | TEXT    | NOT NULL COLLATE NOCASE UNIQUE
    // CURRENCY_TYPE   | TEXT    | NOT NULL (Fiat, Crypto)

    // columns
    static let col_id                 = SQLite.Expression<Int64>("CURRENCYID")
    static let col_name               = SQLite.Expression<String>("CURRENCYNAME")
    static let col_prefixSymbol       = SQLite.Expression<String?>("PFX_SYMBOL")
    static let col_suffixSymbol       = SQLite.Expression<String?>("SFX_SYMBOL")
    static let col_decimalPoint       = SQLite.Expression<String?>("DECIMAL_POINT")
    static let col_groupSeparator     = SQLite.Expression<String?>("GROUP_SEPARATOR")
    static let col_unitName           = SQLite.Expression<String?>("UNIT_NAME")
    static let col_centName           = SQLite.Expression<String?>("CENT_NAME")
    static let col_scale              = SQLite.Expression<Int?>("SCALE")
    static let col_baseConversionRate = SQLite.Expression<Double?>("BASECONVRATE")
    static let col_symbol             = SQLite.Expression<String>("CURRENCY_SYMBOL")
    static let col_type               = SQLite.Expression<String>("CURRENCY_TYPE")

    // cast NUMERIC to REAL
    static let cast_baseConversionRate = cast(col_baseConversionRate) as SQLite.Expression<Double?>


    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_prefixSymbol,
            col_suffixSymbol,
            col_decimalPoint,
            col_groupSeparator,
            col_unitName,
            col_centName,
            col_scale,
            cast_baseConversionRate,
            col_symbol,
            col_type
        )
    }

    static func selectData(_ row: SQLite.Row) -> CurrencyData {
        return CurrencyData(
            id             : row[col_id],
            name           : row[col_name],
            prefixSymbol   : row[col_prefixSymbol] ?? "",
            suffixSymbol   : row[col_suffixSymbol] ?? "",
            decimalPoint   : row[col_decimalPoint] ?? "",
            groupSeparator : row[col_groupSeparator] ?? "",
            unitName       : row[col_unitName] ?? "",
            centName       : row[col_centName] ?? "",
            scale          : row[col_scale] ?? 0,
            baseConvRate   : row[cast_baseConversionRate] ?? 0.0,
            symbol         : row[col_symbol],
            type           : row[col_type]
        )
    }

    func selectFull(_ row: SQLite.Row) -> CurrencyFull {
        let full = CurrencyFull(
            data: Self.selectData(row)
        )
        return full
    }

    static func itemSetters(_ currency: CurrencyData) -> [SQLite.Setter] {
        return [
            col_name               <- currency.name,
            col_prefixSymbol       <- currency.prefixSymbol,
            col_suffixSymbol       <- currency.suffixSymbol,
            col_decimalPoint       <- currency.decimalPoint,
            col_groupSeparator     <- currency.groupSeparator,
            col_unitName           <- currency.unitName,
            col_centName           <- currency.centName,
            col_scale              <- currency.scale,
            col_baseConversionRate <- currency.baseConvRate,
            col_symbol             <- currency.symbol,
            col_type               <- currency.type
        ]
    }
}

extension CurrencyRepository {
    // load data from all currencies
    func load() -> [CurrencyData] {
        return selectData(from: Self.repositoryTable
            .order(Self.col_name)
        )
    }
}
