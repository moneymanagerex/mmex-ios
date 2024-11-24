//
//  TransactionViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/24.
//

import Foundation
import Combine
import SwiftUI
import SQLite

extension ViewModel {
    func loadTransactions(for accountId: DataId? = nil, startDate: Date? = nil, endDate: Date? = nil) {
        let transactionRepository = TransactionRepository(self.db)
        let transactionSplitRepository = TransactionSplitRepository(self.db)
        DispatchQueue.global(qos: .background).async {
            var loadedTransactions = transactionRepository?.loadRecent(accountId: accountId, startDate: startDate, endDate: endDate) ?? []
            for i in loadedTransactions.indices {
                // TODO other better indicator
                if loadedTransactions[i].categId.isVoid {
                    loadedTransactions[i].splits = transactionSplitRepository?.load(for: loadedTransactions[i]) ?? []
                }
            }
            let result = loadedTransactions

            DispatchQueue.main.async {
                self.txns = result.filter { txn in txn.deletedTime.string.isEmpty }
                self.txns_per_day = Dictionary(grouping: self.txns) { txn in
                    // Extract the date portion (ignoring the time) from ISO-8601 string
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format

                    if let date = formatter.date(from: txn.transDate.string) {
                        formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
                        return formatter.string(from: date)
                    }
                    return txn.transDate.string // If parsing fails, return original string
                }
            }
        }
    }
    
    func filterTransactions(by query: String) {
        let filteredTxns = query.isEmpty ? txns : txns.filter { txn in
            txn.notes.localizedCaseInsensitiveContains(query) ||
            txn.splits.contains { split in
                split.notes.localizedCaseInsensitiveContains(query)
            }
        }
        // TODO: refine and consolidate
        self.txns_per_day = Dictionary(grouping: filteredTxns) { txn in
            // Extract the date portion (ignoring the time) from ISO-8601 string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format

            if let date = formatter.date(from: txn.transDate.string) {
                formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
                return formatter.string(from: date)
            }
            return txn.transDate.string // If parsing fails, return original string
        }
    }

    func addTransaction(txn: inout TransactionData) {
        if txn.transCode == .transfer {
            txn.payeeId = 0
        } else {
            txn.toAccountId = 0
        }

        guard let transactionRepository = TransactionRepository(self.db) else { return }

        if transactionRepository.insertWithSplits(&txn) {
            self.txns.append(txn) // id is ready after repo call
        } else {
            // TODO
        }
    }

    func updateTransaction(_ data: inout TransactionData) -> Bool {
        guard let transactionRepository = TransactionRepository(self.db) else { return false }
        return transactionRepository.updateWithSplits(&data)
    }

    func deleteTransaction(_ data: TransactionData) -> Bool {
        guard let transactionRepository = TransactionRepository(self.db) else { return false }
        guard let transactionSplitRepository = TransactionSplitRepository(self.db) else { return false }
        return transactionRepository.delete(data) && transactionSplitRepository.delete(data)
    }
}
