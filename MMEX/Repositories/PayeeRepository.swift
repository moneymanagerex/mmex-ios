//
//  PayeeRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class PayeeRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }
}

extension PayeeRepository {
    // table query
    static let table = Table("PAYEE_V1")

    // table columns
    static let col_id         = Expression<Int64>("PAYEEID")
    static let col_name       = Expression<String>("PAYEENAME")
    static let col_categoryId = Expression<Int64?>("CATEGID")
    static let col_number     = Expression<String?>("NUMBER")
    static let col_website    = Expression<String?>("WEBSITE")
    static let col_notes      = Expression<String?>("NOTES")
    static let col_active     = Expression<Int?>("ACTIVE")
    static let col_pattern    = Expression<String>("PATTERN")
}

extension PayeeRepository {
    // select query
    static let selectQuery = table.select(
        col_id,
        col_name,
        col_categoryId,
        col_number,
        col_website,
        col_notes,
        col_active,
        col_pattern
    )

    // select result
    static func selectResult(_ row: Row) -> Payee {
        return Payee(
            id         : row[col_id],
            name       : row[col_name],
            categoryId : row[col_categoryId],
            number     : row[col_number],
            website    : row[col_website],
            notes      : row[col_notes],
            active     : row[col_active] ?? 1,
            pattern    : row[col_pattern]
        )
    }

    // insert query
    static func insertQuery(_ payee: Payee) -> Insert {
        return table.insert(
            col_name       <- payee.name,
            col_categoryId <- payee.categoryId,
            col_number     <- payee.number,
            col_website    <- payee.website,
            col_notes      <- payee.notes,
            col_active     <- payee.active,
            col_pattern    <- payee.pattern
        )
    }

    // update query
    static func updateQuery(_ payee: Payee) -> Update {
        return table.filter(col_id == payee.id).update(
            col_name       <- payee.name,
            col_categoryId <- payee.categoryId,
            col_number     <- payee.number,
            col_website    <- payee.website,
            col_notes      <- payee.notes,
            col_active     <- payee.active,
            col_pattern    <- payee.pattern
        )
    }

    // delete query
    static func deleteQuery(_ payee: Payee) -> Delete {
        return table.filter(col_id == payee.id).delete()
    }
}

extension PayeeRepository {
    func loadPayees() -> [Payee] {
        guard let db else { return [] }
        do {
            var payees: [Payee] = []
            for row in try db.prepare(PayeeRepository.selectQuery
                .order(PayeeRepository.col_active.desc, PayeeRepository.col_name)
            ) {
                payees.append(PayeeRepository.selectResult(row))
            }
            print("Successfully loaded payees: \(payees.count)")
            return payees
        } catch {
            print("Error loading payees: \(error)")
            return []
        }
    }

    func addPayee(payee: inout Payee) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(PayeeRepository.insertQuery(payee))
            payee.id = rowid
            print("Successfully added payee: \(payee.name), \(payee.id)")
            return true
        } catch {
            print("Failed to add payee: \(error)")
            return false
        }
    }

    func updatePayee(payee: Payee) -> Bool {
        guard let db else { return false }
        do {
            try db.run(PayeeRepository.updateQuery(payee))
            print("Successfully updated payee: \(payee.name)")
            return true
        } catch {
            print("Failed to update payee: \(error)")
            return false
        }
    }

    func deletePayee(payee: Payee) -> Bool {
        guard let db else { return false }
        do {
            try db.run(PayeeRepository.deleteQuery(payee))
            print("Successfully deleted payee: \(payee.name)")
            return true
        } catch {
            print("Failed to delete payee: \(error)")
            return false
        }
    }
}
