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
}
