//
//  CurrencyRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SQLite

class CurrencyRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }
}

extension CurrencyRepository {
    // table query
    static let table = Table("CURRENCYFORMATS_V1")

    // table columns
    static let col_id                 = Expression<Int64>("CURRENCYID")
    static let col_name               = Expression<String>("CURRENCYNAME")
    static let col_prefixSymbol       = Expression<String?>("PFX_SYMBOL")
    static let col_suffixSymbol       = Expression<String?>("SFX_SYMBOL")
    static let col_decimalPoint       = Expression<String?>("DECIMAL_POINT")
    static let col_groupSeparator     = Expression<String?>("GROUP_SEPARATOR")
    static let col_unitName           = Expression<String?>("UNIT_NAME")
    static let col_centName           = Expression<String?>("CENT_NAME")
    static let col_scale              = Expression<Int?>("SCALE")
    static let col_baseConversionRate = Expression<Double?>("BASECONVRATE")
    static let col_symbol             = Expression<String>("CURRENCY_SYMBOL")
    static let col_type               = Expression<String>("CURRENCY_TYPE")

    // cast NUMERIC to REAL
    static let cast_baseConversionRate = cast(col_baseConversionRate) as Expression<Double?>
}

extension CurrencyRepository {
    // select query
    static let selectQuery = table.select(
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

    // select result
    static func selectResult(_ row: Row) -> Currency {
        return Currency(
            id                 : row[col_id],
            name               : row[col_name],
            prefixSymbol       : row[col_prefixSymbol],
            suffixSymbol       : row[col_suffixSymbol],
            decimalPoint       : row[col_decimalPoint],
            groupSeparator     : row[col_groupSeparator],
            unitName           : row[col_unitName],
            centName           : row[col_centName],
            scale              : row[col_scale],
            baseConversionRate : row[cast_baseConversionRate],
            symbol             : row[col_symbol],
            type               : row[col_type]
        )
    }

    // insert query
    static func insertQuery(_ currency: Currency) -> Insert {
        return table.insert(
            col_name               <- currency.name,
            col_prefixSymbol       <- currency.prefixSymbol,
            col_suffixSymbol       <- currency.suffixSymbol,
            col_decimalPoint       <- currency.decimalPoint,
            col_groupSeparator     <- currency.groupSeparator,
            col_unitName           <- currency.unitName,
            col_centName           <- currency.centName,
            col_scale              <- currency.scale,
            col_baseConversionRate <- currency.baseConversionRate,
            col_symbol             <- currency.symbol,
            col_type               <- currency.type
        )
    }

    // update query
    static func updateQuery(_ currency: Currency) -> Update {
        return table.filter(col_id == currency.id).update(
            col_name               <- currency.name,
            col_prefixSymbol       <- currency.prefixSymbol,
            col_suffixSymbol       <- currency.suffixSymbol,
            col_decimalPoint       <- currency.decimalPoint,
            col_groupSeparator     <- currency.groupSeparator,
            col_unitName           <- currency.unitName,
            col_centName           <- currency.centName,
            col_scale              <- currency.scale,
            col_baseConversionRate <- currency.baseConversionRate,
            col_symbol             <- currency.symbol,
            col_type               <- currency.type
        )
    }

    // delete query
    static func deleteQuery(_ currency: Currency) -> Delete {
        return table.filter(col_id == currency.id).delete()
    }
}

extension CurrencyRepository {
    // load all currencies
    func loadCurrencies() -> [Currency] {
        guard let db else { return [] }
        do {
            var currencies: [Currency] = []
            for row in try db.prepare(CurrencyRepository.selectQuery
                .order(CurrencyRepository.col_name)
            ) {
                currencies.append(CurrencyRepository.selectResult(row))
            }
            print("Successfully loaded currencies: \(currencies.count)")
            return currencies
        } catch {
            print("Error loading currencies: \(error)")
            return []
        }
    }

    // add a new currency
    func addCurrency(currency: inout Currency) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(CurrencyRepository.insertQuery(currency))
            currency.id = rowid
            print("Successfully added currency: \(currency.name), \(currency.id)")
            return true
        } catch {
            print("Failed to add currency: \(error)")
            return false
        }
    }

    // update an existing currency
    func updateCurrency(currency: Currency) -> Bool {
        guard let db else { return false }
        do {
            try db.run(CurrencyRepository.updateQuery(currency))
            print("Successfully updated currency: \(currency.name)")
            return true
        } catch {
            print("Failed to update currency: \(error)")
            return false
        }
    }

    // delete a currency
    func deleteCurrency(currency: Currency) -> Bool {
        guard let db else { return false }
        do {
            try db.run(CurrencyRepository.deleteQuery(currency))
            print("Successfully deleted currency: \(currency.name)")
            return true
        } catch {
            print("Failed to delete currency: \(error)")
            return false
        }
    }
}
