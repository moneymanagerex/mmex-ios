//
//  AccountRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class AccountRepository {
    let db: Connection?

    init(db: Connection?) {
        self.db = db
    }

    func loadAccounts() -> [Account] {
        var accounts: [Account] = []
        guard let db = db else { return [] }

        do {
            for row in try db.prepare(Account.table) {
                accounts.append(Account.fromRow(row))
            }
        } catch {
            print("Error loading accounts: \(error)")
        }
        return accounts
    }

    func loadAccountsWithCurrency() -> [(Account, Currency)] {
        let query = Account.table
            .join(Currency.table, on: Account.table[Account.currencyID] == Currency.table[Currency.currencyID])
        // FIXME column name conflict
        
        var accountsWithCurrency: [(Account, Currency)] = []
        guard let db = db else {return []}
        
        do {
            for row in try db.prepare(query) {
                let account = Account.fromRow(row)
                let currency = Currency.fromRow(row)
                accountsWithCurrency.append((account, currency))
            }
        } catch {
            print("Error loading accountswithcurrency: \(error)")
        }
        
        return accountsWithCurrency
    }

    func updateAccount(account: Account) -> Bool {
        let accountToUpdate = Account.table.filter(Account.accountID == account.id)
        do {
            try db?.run(accountToUpdate.update(
                Account.accountName <- account.name,
                Account.status <- account.status.id,
                Account.favoriteAcct <- account.favoriteAcct,
                Account.currencyID <- account.currencyId,
                Account.notes <- account.notes
            ))
            return true
        } catch {
            print("Failed to update account: \(error)")
            return false
        }
    }

    func deleteAccount(account: Account) -> Bool {
        let accountToDelete = Account.table.filter(Account.accountID == account.id)
        do {
            try db?.run(accountToDelete.delete())
            return true
        } catch {
            print("Failed to delete account: \(error)")
            return false
        }
    }

    func addAccount(account: inout Account) -> Bool {
        do {
            let insert = Account.table.insert(
                Account.accountName <- account.name,
                Account.accountType <- account.type,
                Account.status <- account.status.id,
                Account.favoriteAcct <- account.favoriteAcct,
                Account.currencyID <- account.currencyId,
                Account.notes <- account.notes
            )
            let rowid = try db?.run(insert)
            account.id = rowid!
            print("Successfully added account: \(account.name), \(account.id)")
            return true
        } catch {
            print("Failed to add account: \(error)")
            return false
        }
    }
}
