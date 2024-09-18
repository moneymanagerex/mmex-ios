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

    func loadAccountsWithCurrency() -> [Account] {
        // TODO
        guard let db = db else {return []}

        var accounts = loadAccounts();
        let currencies = CurrencyRepository(db:db).loadCurrencies();

        // Create a lookup dictionary for currencies by currencyId
        let currencyDictionary = Dictionary(uniqueKeysWithValues: currencies.map { ($0.id, $0) })
        
        for index in 0...accounts.count - 1 {
            // TODO via join?
            accounts[index].currency = currencyDictionary[accounts[index].currencyId]
        }

        return accounts
    }

    func updateAccount(account: Account) -> Bool {
        let accountToUpdate = Account.table.filter(Account.accountID == account.id)
        do {
            try db?.run(accountToUpdate.update(Account.getSetters(account)))
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
            let insert = Account.table.insert(Account.getSetters(account))
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
