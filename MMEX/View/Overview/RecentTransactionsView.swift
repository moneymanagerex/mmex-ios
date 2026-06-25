//
//  RecentTransactionsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct RecentTransactionsView: View {
    let journals: [JournalData]
    @Binding var selectedFilter: TransactionType?
    let showAccountLabel: Bool
    let formatter: CurrencyFormatter?
    
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    
    private var filteredTransactions: [JournalData] {
        guard let filter = selectedFilter else {
            return Array(journals.sorted { $0.transDate.string > $1.transDate.string }.prefix(7))
        }
        return journals.filter { $0.transCode == filter }
            .sorted { $0.transDate.string > $1.transDate.string }
            .prefix(7)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                if selectedFilter != nil {
                    Button("Clear Filter") {
                        withAnimation {
                            selectedFilter = nil
                        }
                    }
                    .font(.caption)
                }
                // "View All" link placed here
                NavigationLink("View All") {
                    JournalView()
                }
                .font(.caption)
                .foregroundColor(.accentColor)

                if journals.count > 0 {
                    BadgeCount(count: journals.count)
                        .padding(.leading, 4)
                }
            }
            .padding(.horizontal)
            
            if filteredTransactions.isEmpty {
                Text("No transactions in this period")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredTransactions, id: \.id) { txn in
                    NavigationLink(
                        destination: TransactionDetailView(journal: Binding(
                            get: { txn },
                            set: { _ in } // readonly
                        ))
                    ) {
                        TransactionRow(
                            journal: txn,
                            showAccountLabel: showAccountLabel,
                            formatter: formatter
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    Divider()
                }
            }
        }
    }
}

// RecentTransactionsView.swift

struct TransactionRow: View {
    let journal: JournalData
    let showAccountLabel: Bool
    let formatter: CurrencyFormatter?

    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel

    // 计算 Payee 显示名称（与 JournalView 逻辑一致）
    private var payeeDisplayName: String {
        if journal.transCode == .transfer {
            // 转账：显示目标账户名（带箭头方向）
            if let toAccount = vm.accountList.data.readyValue?[journal.toAccountId] {
                return "> \(toAccount.name)"
            } else {
                return "Transfer"
            }
        } else {
            // 普通交易：从 payeeList 获取名称
            if let payee = vm.payeeList.data.readyValue?[journal.payeeId] {
                return payee.name
            } else {
                return "(unknown)"
            }
        }
    }

    // 格式化时间（与 JournalView 一致，显示 h:mm a）
    private func formatTime(_ dateTimeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let dateTime = formatter.date(from: dateTimeString) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: dateTime)
        }
        return dateTimeString
    }

    var body: some View {
        HStack(spacing: 12) {
            let categoryName = vm.categoryList.data.readyValue?[journal.categId]?.name ?? ""
            let symbol = pref.symbol.category2symbol[categoryName] ?? "tag.fill"
            Image(systemName: symbol)
                .frame(width: 30, alignment: .leading)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(payeeDisplayName)
                    .font(.system(size: 16))
                    .lineLimit(1)
                Text(formatTime(journal.transDate.string))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(minWidth: 100, alignment: .leading)

            Spacer()

            Text(journal.transAmount.formatted(by: formatter))
                .frame(alignment: .trailing)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(journal.transCode == .deposit ? .green : .red)
        }
        .padding(.vertical, 2)
    }
}
