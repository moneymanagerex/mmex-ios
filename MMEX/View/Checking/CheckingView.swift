//
//  CheckingView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct CheckingView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var viewModel: TransactionViewModel

    @State private var searchQuery: String = "" // New: Search query
    @State private var accountId: DataId = 0 //
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.txns_per_day.keys.sorted(by: >), id: \.self) { day in
                    Section(
                        header: HStack {
                            Text(humanReadableDate(day))
                                .font(.headline)
                            Spacer()
                            Text("Total: \(calculateTotal(for: day))")
                                .font(.subheadline)
                        }
                    ) {
                        ForEach(viewModel.txns_per_day[day]!, id: \.id) { txn in
                            transactionView(txn, for: day)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Select Account", selection: $accountId) {
                        ForEach(viewModel.accounts) { account in
                            HStack{
                                Image(systemName: account.type.symbolName)
                                    .frame(width: 5, alignment: .leading) // Adjust width as needed
                                    .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                    .foregroundColor(.blue) // Customize icon style
                                Text(account.name)
                            }.tag(account.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Makes it appear as a dropdown
                    .onChange(of: accountId) {
                        viewModel.loadTransactions(for: accountId)
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Search by notes") // New: Search bar
            .onChange(of: searchQuery) { _, query in
                viewModel.filterTransactions(by: query)
            }
        }
        .onAppear {
            accountId = viewModel.defaultAccountId //
            viewModel.loadTransactions(for: accountId)
            viewModel.loadAccounts()
            viewModel.loadCategories()
            viewModel.loadPayees()
        }
    }

    func transactionView(_ txn: TransactionData, for day: String) -> some View {
        NavigationLink(destination: TransactionDetailView(
            viewModel: viewModel,
            accountId: $viewModel.accountId,
            categories: $viewModel.categories,
            payees: $viewModel.payees,
            txn: Binding(
                get: {
                    self.viewModel.txns_per_day[day]?.first(where: { $0.id == txn.id }) ?? txn
                },
                set: { newTxn in
                    if let index = self.viewModel.txns_per_day[day]?.firstIndex(where: { $0.id == txn.id }) {
                        self.viewModel.txns_per_day[day]?[index] = newTxn
                    }
                }
            )
        ) ) {
            HStack {
                // Left column (Category Icon or Category Name)
                if let categorySymbol = CategoryData.categoryToSFSymbol[viewModel.getCategoryName(for: txn.categId)] {
                    Image(systemName: categorySymbol)
                        .frame(width: 50, alignment: .leading) // Adjust width as needed
                        .font(.system(size: 16, weight: .bold)) // Customize size and weight as needed
                        .foregroundColor(.blue) // Customize icon style
                } else {
                    Text(viewModel.getCategoryName(for: txn.categId)) // Fallback to category name if symbol is not found
                        .frame(width: 50, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }

                // Middle column (Payee Name & Time)
                VStack(alignment: .leading, spacing: 4) {
                    Text(getPayeeName(for: txn)) // Payee name
                        .font(.system(size: 16))
                        .lineLimit(1) // Prevent wrapping
                    Text(formatTime(txn.transDate.string)) // Show time in hh:mm a
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(width: 100, alignment: .leading) // Widen middle column, ensuring enough space

                Spacer() // To push the amount to the right side

                if let currencyId = viewModel.accountDict[txn.accountId]?.currencyId,
                   let currencyFormatter = env.currencyCache[currencyId]?.formatter
                {
                    // Right column (Transaction Amount)
                    VStack {
                        // amount in account currency
                        Text(txn.transAmount.formatted(by: currencyFormatter))
                        .frame(alignment: .trailing) // Ensure it's aligned to the right
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                        // amount in base currency
                        if let baseCurrencyId = viewModel.baseCurrency?.id,
                           baseCurrencyId != currencyId,
                           let baseConvRate = env.currencyCache[currencyId]?.baseConvRate
                        {
                            Text((txn.transAmount * baseConvRate)
                                .formatted(by: env.currencyCache[baseCurrencyId]?.formatter)
                            )
                            .frame(alignment: .trailing) // Ensure it's aligned to the right
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                        }
                    }
                } else {
                    // Right column (Transaction Amount)
                    Text(String(format: "%.2f", txn.transAmount))
                        .frame(alignment: .trailing) // Ensure it's aligned to the right
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                }
            }
        }
    }

    func getPayeeName(for txn: TransactionData) -> String {
        // Find the payee with the given ID
        if txn.transCode == .transfer {
            if self.accountId == txn.accountId {
                if let toAccount = viewModel.accountDict[txn.toAccountId] {
                    return String(format: "> \(toAccount.name)")
                }
            } else {
                if let fromAccount = viewModel.accountDict[txn.accountId] {
                    return String(format: "< \(fromAccount.name)")
                }
            }
        }

        return viewModel.getPayeeName(for: txn.payeeId)
    }

    func calculateTotal(for day: String) -> String {
        let transactions = viewModel.txns_per_day[day] ?? []
        let totalAmount = transactions.reduce(0.0) { $0 + $1.actual }
        let account = viewModel.accountDict[accountId]
        return totalAmount.formatted(by: env.currencyCache[account?.currencyId ?? 0]?.formatter)
    }

    func humanReadableDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
        }
        return dateString
    }

    func formatTime(_ dateTimeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Assuming the stored format is ISO-8601
        if let dateTime = formatter.date(from: dateTimeString) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: dateTime)
        }
        return dateTimeString // Fallback if parsing fails
    }
}

#Preview {
    CheckingView(
        viewModel: TransactionViewModel(env: EnvironmentManager.sampleData)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
