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
}

extension AccountRepository {
    // table query
    static let table = Table("ACCOUNTLIST_V1")

    // table columns
    static let col_id              = Expression<Int64>("ACCOUNTID")
    static let col_name            = Expression<String>("ACCOUNTNAME")
    static let col_type            = Expression<String>("ACCOUNTTYPE")
    static let col_num             = Expression<String?>("ACCOUNTNUM")
    static let col_status          = Expression<String>("STATUS")
    static let col_notes           = Expression<String?>("NOTES")
    static let col_heldAt          = Expression<String?>("HELDAT")
    static let col_website         = Expression<String?>("WEBSITE")
    static let col_contactInfo     = Expression<String?>("CONTACTINFO")
    static let col_accessInfo      = Expression<String?>("ACCESSINFO")
    static let col_initialDate     = Expression<String?>("INITIALDATE")
    static let col_initialBal      = Expression<Double?>("INITIALBAL")
    static let col_favoriteAcct    = Expression<String>("FAVORITEACCT")
    static let col_currencyId      = Expression<Int64>("CURRENCYID")
    static let col_statementLocked = Expression<Int?>("STATEMENTLOCKED")
    static let col_statementDate   = Expression<String?>("STATEMENTDATE")
    static let col_minimumBalance  = Expression<Double?>("MINIMUMBALANCE")
    static let col_creditLimit     = Expression<Double?>("CREDITLIMIT")
    static let col_interestRate    = Expression<Double?>("INTERESTRATE")
    static let col_paymentDueDate  = Expression<String?>("PAYMENTDUEDATE")
    static let col_minimumPayment  = Expression<Double?>("MINIMUMPAYMENT")

    // cast NUMERIC to REAL
    static let cast_initialBal     = cast(col_initialBal)     as Expression<Double?>
    static let cast_minimumBalance = cast(col_minimumBalance) as Expression<Double?>
    static let cast_creditLimit    = cast(col_creditLimit)    as Expression<Double?>
    static let cast_interestRate   = cast(col_interestRate)   as Expression<Double?>
    static let cast_minimumPayment = cast(col_minimumPayment) as Expression<Double?>
}

extension AccountRepository {
    // select query
    static let selectQuery = table.select(
        col_id,
        col_name,
        col_type,
        col_num,
        col_status,
        col_notes,
        col_heldAt,
        col_website,
        col_contactInfo,
        col_accessInfo,
        col_initialDate,
        cast_initialBal,
        col_favoriteAcct,
        col_currencyId,
        col_statementLocked,
        col_statementDate,
        cast_minimumBalance,
        cast_creditLimit,
        cast_interestRate,
        col_paymentDueDate,
        cast_minimumPayment
    )

    // select result
    static func selectResult(_ row: Row) -> Account {
        return Account(
            id              : row[col_id],
            name            : row[col_name],
            type            : AccountType(rawValue: row[col_type]) ?? AccountType.cash,
            num             : row[col_num],
            status          : AccountStatus(rawValue: row[col_status]) ?? AccountStatus.open,
            notes           : row[col_notes],
            heldAt          : row[col_heldAt],
            website         : row[col_website],
            contactInfo     : row[col_contactInfo],
            accessInfo      : row[col_accessInfo],
            initialDate     : row[col_initialDate],
            initialBal      : row[cast_initialBal],
            favoriteAcct    : row[col_favoriteAcct],
            currencyId      : row[col_currencyId],
            statementLocked : row[col_statementLocked] ?? 0 == 1,
            statementDate   : row[col_statementDate],
            minimumBalance  : row[cast_minimumBalance],
            creditLimit     : row[cast_creditLimit],
            interestRate    : row[cast_interestRate],
            paymentDueDate  : row[col_paymentDueDate],
            minimumPayment  : row[cast_minimumPayment],
            currency        : nil
        )
    }

    static func insertSetters(_ account: Account) -> [Setter] {
        return [
            col_name            <- account.name,
            col_type            <- account.type.id,
            col_num             <- account.num,
            col_status          <- account.status.id,
            col_notes           <- account.notes,
            col_heldAt          <- account.heldAt,
            col_website         <- account.website,
            col_contactInfo     <- account.contactInfo,
            col_accessInfo      <- account.accessInfo,
            col_initialDate     <- account.initialDate,
            col_initialBal      <- account.initialBal,
            col_favoriteAcct    <- account.favoriteAcct,
            col_currencyId      <- account.currencyId,
            col_statementLocked <- account.statementLocked ?? false ? 1 : 0,
            col_statementDate   <- account.statementDate,
            col_minimumBalance  <- account.minimumBalance,
            col_creditLimit     <- account.creditLimit,
            col_interestRate    <- account.interestRate,
            col_paymentDueDate  <- account.paymentDueDate,
            col_minimumPayment  <- account.minimumPayment
        ]
    }

    // insert query
    static func insertQuery(_ account: Account) -> Insert {
        return table.insert(insertSetters(account))
    }

    // update query
    static func updateQuery(_ account: Account) -> Update {
        return table.filter(col_id == account.id).update(insertSetters(account))
    }

    // delete query
    static func deleteQuery(_ account: Account) -> Delete {
        return table.filter(col_id == account.id).delete()
    }
}

extension AccountRepository {
    func loadAccounts() -> [Account] {
        guard let db else { return [] }
        do {
            var accounts: [Account] = []
            for row in try db.prepare(AccountRepository.selectQuery) {
                accounts.append(AccountRepository.selectResult(row))
            }
            print("Successfully loaded accountss: \(accounts.count)")
            return accounts
        } catch {
            print("Error loading accounts: \(error)")
            return []
        }
    }

    func loadAccountsWithCurrency() -> [Account] {
        // TODO
        guard let db else {return []}

        var accounts = loadAccounts();
        let currencies = CurrencyRepository(db: db).loadCurrencies();

        // Create a lookup dictionary for currencies by currencyId
        let currencyDictionary = Dictionary(uniqueKeysWithValues: currencies.map { ($0.id, $0) })

        for index in 0...accounts.count - 1 {
            // TODO via join?
            accounts[index].currency = currencyDictionary[accounts[index].currencyId]
        }

        return accounts
    }

    func addAccount(account: inout Account) -> Bool {
        guard let db else { return false }
        do {
            let rowid = try db.run(AccountRepository.insertQuery(account))
            account.id = rowid
            print("Successfully added account: \(account.name), \(account.id)")
            return true
        } catch {
            print("Failed to add account: \(error)")
            return false
        }
    }

    func updateAccount(account: Account) -> Bool {
        guard let db else { return false }
        do {
            try db.run(AccountRepository.updateQuery(account))
            print("Successfully updated account: \(account.name)")
            return true
        } catch {
            print("Failed to update account: \(error)")
            return false
        }
    }

    func deleteAccount(account: Account) -> Bool {
        guard let db else { return false }
        do {
            try db.run(AccountRepository.deleteQuery(account))
            print("Successfully deleted account: \(account.name)")
            return true
        } catch {
            print("Failed to delete account: \(error)")
            return false
        }
    }
}
