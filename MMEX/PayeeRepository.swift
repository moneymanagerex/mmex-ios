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

    func loadPayees() -> [Payee] {
        var payees: [Payee] = []
        guard let db = db else { return [] }

        do {
            for payee in try db.prepare(Payee.table) {
                payees.append(Payee(
                    id: payee[Payee.payeeID],
                    name: payee[Payee.payeeName],
                    categoryId: payee[Payee.categoryID],
                    number: payee[Payee.number],
                    website: payee[Payee.website],
                    notes: payee[Payee.notes],
                    active: payee[Payee.active] ?? 1,
                    pattern: payee[Payee.pattern]
                ))
            }
        } catch {
            print("Error loading payees: \(error)")
        }
        return payees
    }

    func updatePayee(payee: Payee) -> Bool {
        let payeeToUpdate = Payee.table.filter(Payee.payeeID == payee.id)
        do {
            try db?.run(payeeToUpdate.update(
                Payee.payeeName <- payee.name,
                Payee.categoryID <- payee.categoryId,
                Payee.number <- payee.number,
                Payee.website <- payee.website,
                Payee.notes <- payee.notes,
                Payee.active <- payee.active,
                Payee.pattern <- payee.pattern
            ))
            return true
        } catch {
            print("Failed to update payee: \(error)")
            return false
        }
    }

    func deletePayee(payee: Payee) -> Bool {
        let payeeToDelete = Payee.table.filter(Payee.payeeID == payee.id)
        do {
            try db?.run(payeeToDelete.delete())
            return true
        } catch {
            print("Failed to delete payee: \(error)")
            return false
        }
    }

    func addPayee(payee: inout Payee) -> Bool {
        do {
            let insert = Payee.table.insert(
                Payee.payeeName <- payee.name,
                Payee.categoryID <- payee.categoryId,
                Payee.number <- payee.number,
                Payee.website <- payee.website,
                Payee.notes <- payee.notes,
                Payee.active <- payee.active,
                Payee.pattern <- payee.pattern
            )
            let rowid = try db?.run(insert)
            payee.id = rowid!
            print("Successfully added payee: \(payee.name), \(payee.id)")
            return true
        } catch {
            print("Failed to add payee: \(error)")
            return false
        }
    }
}
