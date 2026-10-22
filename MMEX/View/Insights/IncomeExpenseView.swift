//
//  IncomeExpenseView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/29.
//

import SwiftUI
import Charts

struct IncomeExpenseView: View {
    let stats: [TransactionData]
    @State private var selectedDate: String?
    @EnvironmentObject var pref: Preference
    
    var body: some View {
        Group {
            if aggregatedStats.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("No income or expense data for this period")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Try a wider date range or add a transaction.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 14) {
                        legendItem("Income", color: pref.theme.incomeColor)
                        legendItem("Expense", color: pref.theme.expenseColor)
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    chart
                }
            }
        }
    }

    private func legendItem(_ title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(title)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(aggregatedStats, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", item.income)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [pref.theme.incomeColor.opacity(0.4), pref.theme.incomeColor.opacity(0.9)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(3)
                .accessibilityLabel("Income: \(item.income.formatted())")
                
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", -item.expense)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [pref.theme.expenseColor.opacity(0.4), pref.theme.expenseColor.opacity(0.9)]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(3)
                .accessibilityLabel("Expense: \(item.expense.formatted())")
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(abs(doubleValue).formatted())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [2]))
                    .foregroundStyle(.gray.opacity(0.3))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisValueLabel {
                    if let dateString = value.as(String.self) {
                        Text(formatDateLabel(dateString))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                    .foregroundStyle(.gray.opacity(0.2))
            }
        }
        .chartLegend(.hidden)
        // .animation(.easeInOut(duration: 0.3), value: stats)
        .frame(height: 150)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
    }
    
    private var aggregatedStats: [DailyIncomeExpense] {
        let grouped = Dictionary(grouping: stats) { txn in
            String(txn.transDate.string.prefix(10))
        }
        return grouped.keys.compactMap { date in
            let dayTxns = grouped[date] ?? []
            let income = dayTxns.filter { $0.transCode == .deposit }.reduce(0) { $0 + $1.transAmount }
            let expense = dayTxns.filter { $0.transCode == .withdrawal }.reduce(0) { $0 + $1.transAmount }
            return DailyIncomeExpense(date: date, income: income, expense: expense)
        }
        .sorted { $0.date < $1.date }
        .suffix(14)
    }
    
    private func formatDateLabel(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month) {
                formatter.dateFormat = "d"
                return formatter.string(from: date)
            } else {
                formatter.dateFormat = "MM/dd"
                return formatter.string(from: date)
            }
        }
        return dateString
    }
}

struct DailyIncomeExpense {
    let date: String
    let income: Double
    let expense: Double
}

#Preview {
    struct InsightsExpensePreview: View {
        var body: some View {
            MMEXPreview.insights("Account Income Summary") { pref, vm in
                IncomeExpenseView(
                    stats: []
                )
            }
        }
    }

    return InsightsExpensePreview()
}
