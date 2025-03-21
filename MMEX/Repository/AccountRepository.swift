//
//  AccountRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct AccountRepository: RepositoryProtocol {
    typealias RepositoryData = AccountData

    let db: Connection

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
    // INITIALDATE     | TEXT    | (yyyy-MM-dd)
    // INITIALBAL      | NUMERIC |
    // FAVORITEACCT    | TEXT    | NOT NULL (FALSE, TRUE)
    // CURRENCYID      | INTEGER | NOT NULL
    // STATEMENTLOCKED | INTEGER |
    // STATEMENTDATE   | TEXT    | (yyyy-MM-dd)
    // MINIMUMBALANCE  | NUMERIC |
    // CREDITLIMIT     | NUMERIC |
    // INTERESTRATE    | NUMERIC |
    // PAYMENTDUEDATE  | TEXT    | (yyyy-MM-dd)
    // MINIMUMPAYMENT  | NUMERIC |

    // column expressions
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

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
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

    static func fetchData(_ row: SQLite.Row) -> AccountData {
        return AccountData(
            id              : DataId(row[col_id]),
            name            : row[col_name],
            type            : AccountType(collateNoCase: row[col_type]),
            num             : row[col_num] ?? "",
            status          : AccountStatus(collateNoCase: row[col_status]),
            notes           : row[col_notes] ?? "",
            heldAt          : row[col_heldAt] ?? "",
            website         : row[col_website] ?? "",
            contactInfo     : row[col_contactInfo] ?? "",
            accessInfo      : row[col_accessInfo] ?? "",
            initialDate     : DateString(row[col_initialDate] ?? ""),
            initialBal      : row[cast_initialBal] ?? 0.0,
            favoriteAcct    : AccountFavorite(collateNoCase: row[col_favoriteAcct]),
            currencyId      : DataId(row[col_currencyId]),
            statementLocked : row[col_statementLocked] ?? 0 > 0,
            statementDate   : DateString(row[col_statementDate] ?? ""),
            minimumBalance  : row[cast_minimumBalance] ?? 0.0,
            creditLimit     : row[cast_creditLimit] ?? 0.0,
            interestRate    : row[cast_interestRate] ?? 0.0,
            paymentDueDate  : DateString(row[col_paymentDueDate] ?? ""),
            minimumPayment  : row[cast_minimumPayment] ?? 0.0
        )
    }

    static func itemSetters(_ data: AccountData) -> [SQLite.Setter] {
        return [
            col_name            <- data.name,
            col_type            <- data.type.id,
            col_num             <- data.num,
            col_status          <- data.status.id,
            col_notes           <- data.notes,
            col_heldAt          <- data.heldAt,
            col_website         <- data.website,
            col_contactInfo     <- data.contactInfo,
            col_accessInfo      <- data.accessInfo,
            col_initialDate     <- data.initialDate.string,
            col_initialBal      <- data.initialBal,
            col_favoriteAcct    <- data.favoriteAcct.rawValue,
            col_currencyId      <- Int64(data.currencyId),
            col_statementLocked <- data.statementLocked ? 1 : 0,
            col_statementDate   <- data.statementDate.string,
            col_minimumBalance  <- data.minimumBalance,
            col_creditLimit     <- data.creditLimit,
            col_interestRate    <- data.interestRate,
            col_paymentDueDate  <- data.paymentDueDate.string,
            col_minimumPayment  <- data.minimumPayment
        ]
    }

    static func filterUsed(_ table: SQLite.Table) -> SQLite.Table {
        typealias I = InfotableRepository
        typealias S = StockRepository
        typealias A = AssetRepository
        typealias T = TransactionRepository
        typealias Q = ScheduledRepository
        let cond = "EXISTS (" + (I.table.select(1).where(
            I.table[I.col_name] == InfoKey.defaultAccountID.rawValue &&
            I.table[I.col_value] == cast(Self.table[Self.col_id]) as SQLite.Expression<String>
        ) ).union(S.table.select(1).where(
            S.table[S.col_accountId] == Self.table[Self.col_id] ||
            S.table[S.col_name] == Self.table[Self.col_name]
        ) ).union(A.table.select(1).where(
            A.table[A.col_name] == Self.table[Self.col_name]
        ) ).union(T.table.select(1).where(
            T.table[T.col_accountId] == Self.table[Self.col_id]
        ) ).union(T.table.select(1).where(
            T.table[T.col_toAccountId] == Self.table[Self.col_id]
        ) ).union(Q.table.select(1).where(
            Q.table[T.col_accountId] == Self.table[Self.col_id]
        ) ).union(Q.table.select(1).where(
            Q.table[T.col_toAccountId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }

    static func filterDeps(_ table: SQLite.Table) -> SQLite.Table {
        typealias D = AttachmentRepository
        let cond = "EXISTS (" + (D.table.select(1).where(
            D.table[D.col_refType] == RefType.account.rawValue &&
            D.table[D.col_refId] == Self.table[Self.col_id]
        ) ).expression.description + ")"
        return table.filter(SQLite.Expression<Bool>(literal: cond))
    }
}

extension AccountRepository {
    // load account flow, indexed by id and transaction status
    func dictFlowByStatus(
        from table: SQLite.Table = Self.table,
        minDate: String? = nil,
        supDate: String? = nil
    ) -> [DataId: AccountFlowByStatus]? {
        let minDate = minDate ?? ""
        let supDate = supDate ?? "z"

        typealias T = TransactionRepository
        let B_query = T.table.select(
            T.col_accountId,
            T.col_status,
            T.col_transAmount, 0
        )
            .where(
                T.col_transCode == "Deposit" &&
                T.col_transDate ?? "" >= minDate &&
                T.col_transDate ?? "" <  supDate &&
                T.col_deletedTime ?? "" == ""
            )
        .union(all: true, T.table.select(
            T.col_accountId,
            T.col_status,
            0, T.col_transAmount
        )
            .where(
                T.col_transCode == "Withdrawal" &&
                T.col_transDate ?? "" >= minDate &&
                T.col_transDate ?? "" <  supDate &&
                T.col_deletedTime ?? "" == ""
            )
        ).union(all: true, T.table.select(
            T.col_accountId,
            T.col_status,
            0, T.col_transAmount
        )
            .where(
                T.col_transCode == "Transfer" &&
                T.col_transDate ?? "" >= minDate &&
                T.col_transDate ?? "" <  supDate &&
                T.col_deletedTime ?? "" == ""
            )
        ).union(all: true, T.table.select(
            T.col_toAccountId,
            T.col_status,
            T.col_toTransAmount, 0
        )
            .where(
                T.col_transCode == "Transfer" &&
                T.col_transDate ?? "" >= minDate &&
                T.col_transDate ?? "" <  supDate &&
                T.col_deletedTime ?? "" == ""
            )
        )

        typealias A = Self
        let B_table = SQLite.Table("b")
        let B_col_inflow  = SQLite.Expression<Double>("INFLOW")
        let B_col_outflow = SQLite.Expression<Double>("OUTFLOW")
        let query = table.with(
            B_table,
            columns: [A.col_id, T.col_status, B_col_inflow, B_col_outflow],
            recursive: false,
            as: B_query
        )
            .join(B_table, on: B_table[A.col_id] == A.table[A.col_id])
            .where(A.table[A.col_type] != "Investment")
            .select(
                A.table[A.col_id],
                B_table[T.col_status],
                B_table[B_col_inflow].total,
                B_table[B_col_outflow].total
            )
            .group(A.table[A.col_id], B_table[T.col_status])

        log.trace("DEBUG: AccountRepository.dictFlowByStatus(): \(query.expression.description)")
        do {
            var dict: [DataId: AccountFlowByStatus] = [:]
            for row in try db.prepare(query) {
                let id = DataId(row[A.table[A.col_id]])
                let status = TransactionStatus(collateNoCase: row[B_table[T.col_status]])
                if dict[id] == nil { dict[id] = [:] }
                dict[id]![status] = AccountFlow(
                    inflow  : row[B_table[B_col_inflow].total],
                    outflow : row[B_table[B_col_outflow].total]
                )
            }
            log.info("INFO: AccountRepository.dictFlowByStatus(): \(dict.count)")
            return dict
        } catch {
            log.error("ERROR: AccountRepository.dictFlowByStatus(): \(error)")
            return nil
        }
    }
}
