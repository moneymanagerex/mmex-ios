//
//  FinancialSummaryCard.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct FinancialSummaryCard: View {
    let netWorth: Double
    let previousNetWorth: Double
    let netWorthChange: Double
    let income: Double
    let expense: Double
    let incomeChange: Double
    let expenseChange: Double
    @Binding var selectedFilter: TransactionType?
    let formatter: CurrencyFormatter?
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            netWorthRow
            
            Divider()
                .padding(.vertical, 8)
            
            HStack(spacing: 12) {
                MetricCard(
                    title: "Income",
                    icon: "arrow.down.circle.fill",
                    amount: income,
                    change: incomeChange,
                    filterType: .deposit,
                    isSelected: selectedFilter == .deposit,
                    formatter: formatter,
                    onTap: { selectedFilter = (selectedFilter == .deposit ? nil : .deposit) }
                )
                
                MetricCard(
                    title: "Expense",
                    icon: "arrow.up.circle.fill",
                    amount: expense,
                    change: expenseChange,
                    filterType: .withdrawal,
                    isSelected: selectedFilter == .withdrawal,
                    formatter: formatter,
                    onTap: { selectedFilter = (selectedFilter == .withdrawal ? nil : .withdrawal) }
                )
            }
            
            if !vm.overviewTransactions.isEmpty {
                Divider()
                    .padding(.vertical, 8)
                
                miniTrendChart
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
        .padding(.horizontal, 8)
    }
    
    // MARK: - Subviews
    
    private var netWorthRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Net Worth")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(netWorth.formatted(by: formatter))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(netWorth >= 0 ? .primary : .red)
            }
            
            Spacer()
            
            if netWorthChange != 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: netWorthChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(String(format: "%.1f%%", abs(netWorthChange)))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(netWorthChange >= 0 ? .green : .red)
                    
                    if previousNetWorth != 0 {
                        Text("vs \(previousNetWorth.formatted(by: formatter))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var miniTrendChart: some View {
        HStack(spacing: 2) {
            ForEach(Array(vm.overviewTransactions.prefix(30)), id: \.id) { txn in
                let isPositive = txn.transCode == .deposit
                let height = CGFloat(min(abs(txn.transAmount) / 100 + 2, 20))
                Rectangle()
                    .fill(isPositive ? Color.green : Color.red)
                    .frame(width: 4, height: height)
            }
        }
        .frame(height: 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Metric Card (子组件)

struct MetricCard: View {
    let title: String
    let icon: String
    let amount: Double
    let change: Double
    let filterType: TransactionType?
    let isSelected: Bool
    let formatter: CurrencyFormatter?
    let onTap: () -> Void
    
    private var amountColor: Color {
        filterType == .deposit ? .green : .red
    }
    
    private var changeColor: Color {
        change >= 0 ? .green : .red
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 6)
                    }
                }
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text(amount.formatted(by: formatter))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(amountColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    if change != 0 {
                        HStack(spacing: 2) {
                            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                            Text(String(format: "%.1f%%", abs(change)))
                                .font(.caption)
                        }
                        .foregroundColor(changeColor)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.gray.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
