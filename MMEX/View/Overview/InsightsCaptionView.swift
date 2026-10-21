//
//  InsightsCaptionView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct InsightsCaptionView: View {
    let transactions: [TransactionData]
    let startDate: Date?
    let endDate: Date?

    init(
        transactions: [TransactionData],
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.transactions = transactions
        self.startDate = startDate
        self.endDate = endDate
    }

    var body: some View {
        if transactions.isEmpty {
            Text("No transactions in this period.")
                .font(.caption).foregroundColor(.secondary)
        } else {
            let expenseTotal = transactions
                .filter { $0.transCode == .withdrawal }
                .reduce(0) { $0 + $1.transAmount }

            let range = effectiveRange
            let days = max(1, Calendar.current.dateComponents(
                [.day], from: range.start, to: range.end
            ).day.map { $0 + 1 } ?? 1)
            let avgDaily = expenseTotal / Double(days)

            Text("💡 Daily avg: \(String(format: "%.1f", avgDaily)), total: \(String(format: "%.1f", expenseTotal))")
                .font(.caption).foregroundColor(.secondary)
        }
    }

    private var effectiveRange: (start: Date, end: Date) {
        let cal = Calendar.current
        if let s = startDate, let e = endDate {
            return (cal.startOfDay(for: s), cal.startOfDay(for: e))
        }
        let dates = transactions.compactMap { $0.transDate.optDate }
        let start = dates.min() ?? Date()
        let end = dates.max() ?? Date()
        return (cal.startOfDay(for: start), cal.startOfDay(for: end))
    }
}

extension Calendar {
    func numberOfDaysInCurrentMonth() -> Int {
        let range = range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }
}
