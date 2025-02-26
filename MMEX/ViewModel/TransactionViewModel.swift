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
    nonisolated func loadTransactions(
        db: SQLite.Connection?,
        for accountId: DataId? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) async -> [TransactionData] {
        log.debug("DEBUG: ViewModel.loadTransactions()")
        guard
            let t  = TransactionRepository(db),
            let tp = TransactionSplitRepository(db)
        else { return [] }
        var data = t.loadRecent(accountId: accountId, startDate: startDate, endDate: endDate) ?? []
        for i in data.indices {
            // TODO other better indicator
            if data[i].categId.isVoid {
                data[i].splits = tp.load(for: data[i]) ?? []
            }
        }
        return data
    }

    func groupTransactions(_ data: [TransactionData]) {
        log.debug("DEBUG: ViewModel.groupTransactions()")
        self.txns = data.filter { txn in txn.deletedTime.string.isEmpty }
        self.txns_per_day = Dictionary(grouping: self.txns) { txn in
            String(txn.transDate.string.prefix(10))
        }
    }

    func filterTransactions(by query: String) {
        log.debug("DEBUG: ViewModel.filterTransactions(\(query)")

        var payeeIdOffer: Set<DataId> = []
        var categoryOffer: Set<DataId> = []

        if query.isEmpty {
            payeeIdOffer = Set(payeeList.order.readyValue ?? [])
            categoryOffer = Set(categoryList.order.readyValue ?? [])
        } else {
            for (id, payee) in payeeList.data.readyValue ?? [:] {
                if payee.name.localizedCaseInsensitiveContains(query) {
                    payeeIdOffer.insert(id)
                }
            }

            for (id, category) in categoryList.evalPath.readyValue ?? [:] {
                if category.localizedCaseInsensitiveContains(query) {
                    categoryOffer.insert(id)
                }
            }
        }

        let filteredTxns = query.isEmpty ? txns : txns.filter { txn in
            txn.notes.localizedCaseInsensitiveContains(query) ||
            txn.splits.contains { split in
                split.notes.localizedCaseInsensitiveContains(query)
                || categoryOffer.contains(split.categId)
            }
            || payeeIdOffer.contains(txn.payeeId)
            || categoryOffer.contains(txn.categId)
        }
        self.txns_per_day = Dictionary(grouping: filteredTxns) { txn in
            String(txn.transDate.string.prefix(10))
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
