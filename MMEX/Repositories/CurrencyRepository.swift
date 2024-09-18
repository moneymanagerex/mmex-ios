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

    // Load all currencies from the database
    func loadCurrencies() -> [Currency] {
        var currencies: [Currency] = []
        guard let db = db else { return [] }

        do {
            for row in try db.prepare(Currency.table) {
                currencies.append(Currency.fromRow(row))
            }
        } catch {
            print("Error loading currencies: \(error)")
        }

        return currencies
    }

    // Add a new currency
    func addCurrency(currency: inout Currency) -> Bool {
        do {
            let insert = Currency.table.insert(
                Currency.currencyName <- currency.name,
                Currency.prefixSymbol <- currency.prefixSymbol,
                Currency.suffixSymbol <- currency.suffixSymbol,
                Currency.decimalPoint <- currency.decimalPoint,
                Currency.groupSeparator <- currency.groupSeparator,
                Currency.unitName <- currency.unitName,
                Currency.centName <- currency.centName,
                Currency.scale <- currency.scale,
                Currency.baseConversionRate <- currency.baseConversionRate ?? 0.0,
                Currency.symbol <- currency.symbol,
                Currency.type <- currency.type
            )
            let rowid = try db?.run(insert)
            currency.id = rowid!
            print("Successfully added currency: \(currency.name), \(currency.id)")
            return true
        } catch {
            print("Failed to add currency: \(error)")
            return false
        }
    }

    // Update an existing currency
    func updateCurrency(currency: Currency) -> Bool {
        let currencyToUpdate = Currency.table.filter(Currency.currencyID == currency.id)
        do {
            try db?.run(currencyToUpdate.update(
                Currency.currencyName <- currency.name,
                Currency.prefixSymbol <- currency.prefixSymbol,
                Currency.suffixSymbol <- currency.suffixSymbol,
                Currency.decimalPoint <- currency.decimalPoint,
                Currency.groupSeparator <- currency.groupSeparator,
                Currency.unitName <- currency.unitName,
                Currency.centName <- currency.centName,
                Currency.scale <- currency.scale,
                Currency.baseConversionRate <- currency.baseConversionRate,
                Currency.symbol <- currency.symbol,
                Currency.type <- currency.type
            ))
            print("Successfully updated currency: \(currency.name)")
            return true
        } catch {
            print("Failed to update currency: \(error)")
            return false
        }
    }

    // Delete a currency
    func deleteCurrency(currency: Currency) -> Bool {
        let currencyToDelete = Currency.table.filter(Currency.currencyID == currency.id)
        do {
            try db?.run(currencyToDelete.delete())
            print("Successfully deleted currency: \(currency.name)")
            return true
        } catch {
            print("Failed to delete currency: \(error)")
            return false
        }
    }
}
