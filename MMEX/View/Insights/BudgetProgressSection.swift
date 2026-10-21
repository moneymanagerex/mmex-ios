//
//  BudgetProgressSection.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/10/21.
//

import SwiftUI

struct BudgetProgressSection: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var insights: InsightsViewModel
    let formatter: CurrencyFormatter?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if insights.budgetIsLoading {
                loading
            } else if let summary = insights.budgetSummary, !summary.items.isEmpty {
                header(summary)
                ForEach(summary.items) { row($0) }
            } else {
                empty
            }
        }
        .task {
            if insights.budgetSummary == nil { insights.loadBudget(from: vm) }
        }
        .onChange(of: vm.budgetList.state) { _, newState in
            if newState == .ready { insights.loadBudget(from: vm) }
        }
    }

    @ViewBuilder private var loading: some View {
        HStack {
            ProgressView().scaleEffect(0.7)
            Text("Loading budgets...").font(.caption).foregroundColor(.secondary)
        }.padding(.vertical, 8)
    }

    @ViewBuilder private func header(_ summary: BudgetProgressSummary) -> some View {
        HStack {
            Text(summary.periodName).font(.subheadline).fontWeight(.medium)
            Spacer()
            if summary.overCount > 0 {
                Label("\(summary.overCount) over", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption).foregroundColor(pref.theme.expenseColor)
            } else {
                Label("On track", systemImage: "checkmark.circle.fill")
                    .font(.caption).foregroundColor(pref.theme.incomeColor)
            }
        }
    }

    @ViewBuilder private func row(_ item: BudgetProgressItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.categoryPath).font(.subheadline).lineLimit(1)
                Spacer(minLength: 8)
                Text("\(item.actual.formatted(by: formatter)) / \(item.target.formatted(by: formatter))")
                    .font(.caption)
                    .foregroundColor(item.isOver ? pref.theme.expenseColor : .secondary)
            }
            ProgressView(value: min(item.progress, 1.0))
                .tint(item.isOver
                      ? pref.theme.expenseColor
                      : (item.status == .nearLimit ? .orange : pref.theme.incomeColor))
            HStack {
                Text(item.isExpense ? "Spent" : "Earned")
                    .font(.caption2).foregroundColor(.secondary)
                Spacer()
                if item.isOver {
                    Text("Over by \(abs(item.variance).formatted(by: formatter))")
                        .font(.caption2).foregroundColor(pref.theme.expenseColor)
                } else {
                    Text("\(item.remaining.formatted(by: formatter)) left")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder private var empty: some View {
        HStack {
            Image(systemName: "target").foregroundColor(.secondary)
            Text("No budgets defined for the current period.")
                .font(.caption).foregroundColor(.secondary)
            Spacer()
        }.padding(.vertical, 8)
    }
}
