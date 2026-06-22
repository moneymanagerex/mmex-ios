//
//  InsightsCaptionView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct InsightsCaptionView: View {
    let transactions: [TransactionData]
    
    var body: some View {
        if transactions.isEmpty {
            Text("No transactions in this period.")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            let expenseTotal = transactions.filter { $0.transCode == .withdrawal }
                .reduce(0) { $0 + $1.transAmount }
            let days = Calendar.current.numberOfDaysInCurrentMonth()
            let avgDaily = expenseTotal / Double(days)
            Text("💡 Daily avg: \(String(format: "%.1f", avgDaily)), total: \(String(format: "%.1f", expenseTotal))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

extension Calendar {
    func numberOfDaysInCurrentMonth() -> Int {
        let range = range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }
}
