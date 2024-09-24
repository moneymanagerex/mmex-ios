//
//  AccountRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class AccountRepository: RepositoryProtocol {
    typealias RepositoryData = AccountData

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "ACCOUNTLIST_V1"
    static let table = SQLite.Table(repositoryName)

    // column          | type    | other
    // ----------------+---------+------
    // ACCOUNTID       | INTEGER | PRIMARY KEY
    // ACCOUNTNAME     | TEXT    | NOT NULL COLLATE NOCASE UNIQUE
    // ACCOUNTTYPE     | TEXT    | NOT NULL (Cash, Checking, ...)
    // ACCOUNTNUM      | TEXT    |
    // STATUS          | TEXT    | NOT NULL (Open, Closed)
    // NOTES           | TEXT    |
    // HELDAT          | TEXT    |
    // WEBSITE         | TEXT    |
    // CONTACTINFO     | TEXT    |
    // ACCESSINFO      | TEXT    |
    // INITIALDATE     | TEXT    |
    // INITIALBAL      | NUMERIC |
    // FAVORITEACCT    | TEXT    | NOT NULL
    // CURRENCYID      | INTEGER | NOT NULL
    // STATEMENTLOCKED | INTEGER |
    // STATEMENTDATE   | TEXT    |
    // MINIMUMBALANCE  | NUMERIC |
    // CREDITLIMIT     | NUMERIC |
    // INTERESTRATE    | NUMERIC |
    // PAYMENTDUEDATE  | TEXT    |
    // MINIMUMPAYMENT  | NUMERIC |

    // columns
    static let col_id              = SQLite.Expression<Int64>("ACCOUNTID")
    static let col_name            = SQLite.Expression<String>("ACCOUNTNAME")
    static let col_type            = SQLite.Expression<String>("ACCOUNTTYPE")
    static let col_num             = SQLite.Expression<String?>("ACCOUNTNUM")
    static let col_status          = SQLite.Expression<String>("STATUS")
    static let col_notes           = SQLite.Expression<String?>("NOTES")
    static let col_heldAt          = SQLite.Expression<String?>("HELDAT")
    static let col_website         = SQLite.Expression<String?>("WEBSITE")
    static let col_contactInfo     = SQLite.Expression<String?>("CONTACTINFO")
    static let col_accessInfo      = SQLite.Expression<String?>("ACCESSINFO")
    static let col_initialDate     = SQLite.Expression<String?>("INITIALDATE")
    static let col_initialBal      = SQLite.Expression<Double?>("INITIALBAL")
    static let col_favoriteAcct    = SQLite.Expression<String>("FAVORITEACCT")
    static let col_currencyId      = SQLite.Expression<Int64>("CURRENCYID")
    static let col_statementLocked = SQLite.Expression<Int?>("STATEMENTLOCKED")
    static let col_statementDate   = SQLite.Expression<String?>("STATEMENTDATE")
    static let col_minimumBalance  = SQLite.Expression<Double?>("MINIMUMBALANCE")
    static let col_creditLimit     = SQLite.Expression<Double?>("CREDITLIMIT")
    static let col_interestRate    = SQLite.Expression<Double?>("INTERESTRATE")
    static let col_paymentDueDate  = SQLite.Expression<String?>("PAYMENTDUEDATE")
    static let col_minimumPayment  = SQLite.Expression<Double?>("MINIMUMPAYMENT")

    // cast NUMERIC to REAL
    static let cast_initialBal     = cast(col_initialBal)     as SQLite.Expression<Double?>
    static let cast_minimumBalance = cast(col_minimumBalance) as SQLite.Expression<Double?>
    static let cast_creditLimit    = cast(col_creditLimit)    as SQLite.Expression<Double?>
    static let cast_interestRate   = cast(col_interestRate)   as SQLite.Expression<Double?>
    static let cast_minimumPayment = cast(col_minimumPayment) as SQLite.Expression<Double?>

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
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
    }

    static func selectData(_ row: SQLite.Row) -> AccountData {
        return AccountData(
            id              : row[col_id],
            name            : row[col_name],
            type            : AccountType(collateNoCase: row[col_type]),
            num             : row[col_num] ?? "",
            status          : AccountStatus(collateNoCase: row[col_status]),
            notes           : row[col_notes] ?? "",
            heldAt          : row[col_heldAt] ?? "",
            website         : row[col_website] ?? "",
            contactInfo     : row[col_contactInfo] ?? "",
            accessInfo      : row[col_accessInfo] ?? "",
            initialDate     : row[col_initialDate] ?? "",
            initialBal      : row[cast_initialBal] ?? 0.0,
            favoriteAcct    : row[col_favoriteAcct],
            currencyId      : row[col_currencyId],
            statementLocked : row[col_statementLocked] ?? 0 > 0,
            statementDate   : row[col_statementDate] ?? "",
            minimumBalance  : row[cast_minimumBalance] ?? 0.0,
            creditLimit     : row[cast_creditLimit] ?? 0.0,
            interestRate    : row[cast_interestRate] ?? 0.0,
            paymentDueDate  : row[col_paymentDueDate] ?? "",
            minimumPayment  : row[cast_minimumPayment] ?? 0.0
        )
    }

    static func itemSetters(_ account: AccountData) -> [SQLite.Setter] {
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
            col_statementLocked <- account.statementLocked ? 1 : 0,
            col_statementDate   <- account.statementDate,
            col_minimumBalance  <- account.minimumBalance,
            col_creditLimit     <- account.creditLimit,
            col_interestRate    <- account.interestRate,
            col_paymentDueDate  <- account.paymentDueDate,
            col_minimumPayment  <- account.minimumPayment
        ]
    }
}

extension AccountRepository {
    // load all accounts
    func load() -> [AccountData] {
        return select(from: Self.table
            .order(Self.col_name)
        )
    }
}

// TODO: move to ViewModels
extension AccountRepository {
    // load all accounts and their currency
    func loadWithCurrency() -> [AccountWithCurrency] {
        // TODO via join?
        guard let db else {return []}
        
        // Create a lookup dictionary for currencies by currencyId
        let currencies = CurrencyRepository(db: db).load();
        let currencyDict = Dictionary(uniqueKeysWithValues: currencies.map { ($0.id, $0) })

        do {
            var data: [AccountWithCurrency] = []
            for row in try db.prepare(Self.selectQuery(from: Self.table
                .order(Self.col_name)
            )) {
                let account = Self.selectData(row)
                data.append(AccountWithCurrency(
                    data: account,
                    currency: currencyDict[account.currencyId]
                ) )
            }
            print("Successfull select from \(Self.repositoryName): \(data.count)")
            return data
        } catch {
            print("Failed select from \(Self.repositoryName): \(error)")
            return []
        }
    }
}
