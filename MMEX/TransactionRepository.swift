//
//  CheckingRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

class TransactionRepository {
    let db: Connection?
    
    init(db: Connection?) {
        self.db = db
    }
    
    func addTransaction(txn: inout Transaction) -> Bool {
        do {
            let insert = Transaction.table.insert(
                Transaction.accountIDExpr <- txn.accountID,
                Transaction.toAccountIDExpr <- txn.toAccountID,
                Transaction.payeeIDExpr <- txn.payeeID,
                Transaction.transCodeExpr <- txn.transode.id,
                Transaction.transAmountExpr <- txn.transAmount,
                Transaction.statusExpr <- txn.status.id,
                Transaction.transactionNumberExpr <- txn.transactionNumber,
                Transaction.notesExpr <- txn.notes,
                Transaction.categIDExpr <- txn.categID,
                Transaction.transDateExpr <- txn.transDate,
                Transaction.lastUpdatedTimeExpr <- txn.lastUpdatedTime,
                Transaction.deletedTimeExpr <- txn.deletedTime,
                Transaction.followUpIDExpr <- txn.followUpID,
                Transaction.toTransAmountExpr <- txn.toTransAmount,
                Transaction.colorExpr <- txn.color
            )
            let rowid = try db?.run(insert)
            txn.id = rowid!
            print("Successfully added transaction with ID: \(txn.id), \(txn)")
            return true
        } catch {
            print("Failed to add transaction: \(error)")
            return false
        }
    }
    
    func updateTransaction(txn: Transaction) -> Bool {
        let accountToUpdate = Transaction.table.filter(Transaction.transID == txn.id)
        do {
            try db?.run(accountToUpdate.update(
                Transaction.accountIDExpr <- txn.accountID,
                Transaction.toAccountIDExpr <- txn.toAccountID,
                Transaction.payeeIDExpr <- txn.payeeID,
                Transaction.transCodeExpr <- txn.transode.id,
                Transaction.transAmountExpr <- txn.transAmount,
                Transaction.statusExpr <- txn.status.id,
                Transaction.transactionNumberExpr <- txn.transactionNumber,
                Transaction.notesExpr <- txn.notes,
                Transaction.categIDExpr <- txn.categID,
                Transaction.transDateExpr <- txn.transDate,
                Transaction.lastUpdatedTimeExpr <- txn.lastUpdatedTime,
                Transaction.deletedTimeExpr <- txn.deletedTime,
                Transaction.followUpIDExpr <- txn.followUpID,
                Transaction.toTransAmountExpr <- txn.toTransAmount,
                Transaction.colorExpr <- txn.color
            ))
            return true
        } catch {
            print("Failed to update transaction: \(error)")
            return false
        }
    }
    
    func deleteTransaction(txn: Transaction) -> Bool {
        let accountToDelete = Transaction.table.filter(Transaction.transID == txn.id)
        do {
            try db?.run(accountToDelete.delete())
            return true
        } catch {
            print("Failed to delete transaction: \(error)")
            return false
        }
    }
    
    // Fetch all Checking Accounts
    func loadTransactions() -> [Transaction] {
        var results: [Transaction] = []
        guard let db = db else { return [] }

        do {
            for txn in try db.prepare(Transaction.table) {
                results.append(Transaction(
                    id: txn[Transaction.transID],
                    accountID: txn[Transaction.accountIDExpr],
                    toAccountID: txn[Transaction.toAccountIDExpr],
                    payeeID: txn[Transaction.payeeIDExpr],
                    transCode: Transcode(rawValue: txn[Transaction.transCodeExpr]) ?? Transcode.deposit,
                    transAmount: txn[Transaction.transAmountExpr],
                    status: TransactionStatus(rawValue: txn[Transaction.statusExpr] ?? "") ?? TransactionStatus.none,
                    transactionNumber: txn[Transaction.transactionNumberExpr],
                    notes: txn[Transaction.notesExpr],
                    categID: txn[Transaction.categIDExpr],
                    transDate: txn[Transaction.transDateExpr],
                    lastUpdatedTime: txn[Transaction.lastUpdatedTimeExpr],
                    deletedTime: txn[Transaction.deletedTimeExpr],
                    followUpID: txn[Transaction.followUpIDExpr],
                    toTransAmount: txn[Transaction.toTransAmountExpr],
                    color: txn[Transaction.colorExpr]
                ))
            }
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
        
        return results
    }
    
    func loadRecentTransactions() -> [Transaction] {
        let currentDate = Date()
        var startDate: Date? = Calendar.current.date(byAdding: .month, value: -3, to: currentDate)

        
        var results: [Transaction] = []
        guard let db = db else { return [] }

        do {
            var query = Transaction.table
            // If startDate is set, add filtering by date range
            if let startDate = startDate {
                query = query.filter(Transaction.transDateExpr >= startDate.ISO8601Format())
            }
            
            for txn in try db.prepare(query) {
                results.append(Transaction(
                    id: txn[Transaction.transID],
                    accountID: txn[Transaction.accountIDExpr],
                    toAccountID: txn[Transaction.toAccountIDExpr],
                    payeeID: txn[Transaction.payeeIDExpr],
                    transCode: Transcode(rawValue: txn[Transaction.transCodeExpr]) ?? Transcode.deposit,
                    transAmount: txn[Transaction.transAmountExpr] ?? 0.0,
                    status: TransactionStatus(rawValue: txn[Transaction.statusExpr] ?? "") ?? TransactionStatus.none,
                    transactionNumber: txn[Transaction.transactionNumberExpr],
                    notes: txn[Transaction.notesExpr],
                    categID: txn[Transaction.categIDExpr],
                    transDate: txn[Transaction.transDateExpr],
                    lastUpdatedTime: txn[Transaction.lastUpdatedTimeExpr],
                    deletedTime: txn[Transaction.deletedTimeExpr],
                    followUpID: txn[Transaction.followUpIDExpr],
                    toTransAmount: txn[Transaction.toTransAmountExpr],
                    color: txn[Transaction.colorExpr]
                ))
            }
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
        
        return results
    }
}
