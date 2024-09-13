//
//  TransactionListView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView2: View {
    let databaseURL: URL
    @State private var txns: [Transaction] = []
    @State private var txns_per_day: [String: [Transaction]] = [:]
    @State private var payees: [Payee] = []
    @State private var categories: [Category] = []
    @State private var accounts: [Account] = []
    @State private var accountsWithCurrency: [(Account, Currency)] = []

    private var repository: TransactionRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getTransactionRepository()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(txns_per_day.keys.sorted(by: >), id: \.self) { day in
                    Section(
                        header: HStack {
                            Text(humanReadableDate(day))
                                .font(.headline)
                            Spacer()
                            Text("Total: \(calculateTotal(for: day))")
                                .font(.subheadline)
                        }
                    ) {
                        ForEach(txns_per_day[day]!, id: \.id) { txn in
                            NavigationLink(destination: TransactionDetailView(txn: txn, databaseURL: databaseURL, payees: $payees, categories: $categories, accounts: $accounts)) {
                                HStack {
                                    // Left column (Category Icon or Category Name)
                                    if let categorySymbol = Category.categoryToSFSymbol[getCategoryName(for: txn.categID ?? 0)] {
                                        Image(systemName: categorySymbol)
                                            .frame(width: 50, alignment: .leading) // Adjust width as needed
                                            .font(.system(size: 16, weight: .bold)) // Customize size and weight as needed
                                            .foregroundColor(.blue) // Customize icon style
                                    } else {
                                        Text(getCategoryName(for: txn.categID ?? 0)) // Fallback to category name if symbol is not found
                                            .frame(width: 50, alignment: .leading)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.blue)
                                    }

                                    // Middle column (Payee Name & Time)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(getPayeeName(for: txn.payeeID)) // Payee name
                                            .font(.system(size: 16))
                                            .lineLimit(1) // Prevent wrapping
                                        Text(formatTime(txn.transDate)) // Show time in hh:mm a
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 100, alignment: .leading) // Widen middle column, ensuring enough space

                                    Spacer() // To push the amount to the right side

                                    if let accountWithCurrency = getAccountWithCurrency(for: txn.accountID) {
                                        // Right column (Transaction Amount)
                                        //  Text(String(format: "%.2f", txn.transAmount ?? 0.0))
                                        Text(accountWithCurrency.1.format(amount: txn.transAmount ?? 0.0))
                                            .frame(alignment: .trailing) // Ensure it's aligned to the right
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(txn.transAmount ?? 0.0 >= 0 ? .green : .red) // Positive/negative amount color
                                    } else {
                                        // Right column (Transaction Amount)
                                        Text(String(format: "%.2f", txn.transAmount ?? 0.0))
                                            .frame(alignment: .trailing) // Ensure it's aligned to the right
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(txn.transAmount ?? 0.0 >= 0 ? .green : .red) // Positive/negative amount color
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadTransactions()
            loadPayees()
            loadCategories()
            loadAccounts()
        }
    }
    
    func loadTransactions() {
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = repository.loadRecentTransactions()
            
            DispatchQueue.main.async {
                self.txns = loadTransactions
                self.txns_per_day = Dictionary(grouping: txns) { txn in
                    // Extract the date portion (ignoring the time) from ISO-8601 string
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format
                    
                    if let date = formatter.date(from: txn.transDate) {
                        formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
                        return formatter.string(from: date)
                    }
                    return txn.transDate // If parsing fails, return original string
                }
            }
        }
    }
    
    func loadPayees() {
        let repository = DataManager(databaseURL: self.databaseURL).getPayeeRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository.loadPayees()
            
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }
    
    func loadCategories() {
        let repository = DataManager(databaseURL: self.databaseURL).getCategoryRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository.loadCategories()
            
            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }
    
    func loadAccounts() {
        let repository = DataManager(databaseURL: self.databaseURL).getAccountRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository.loadAccounts()
            let loadedAccountsWithCurrency = repository.loadAccountsWithCurrency()
            
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
                self.accountsWithCurrency = loadedAccountsWithCurrency
            }
        }
    }

    // TODO pre-join via SQL?
    func getPayeeName(for payeeID: Int64) -> String {
        // Find the payee with the given ID
        return payees.first { $0.id == payeeID }?.name ?? "Unknown"
    }
    
    // TODO pre-join via SQL?
    func getCategoryName(for categoryID: Int64) -> String {
        // Find the category with the given ID
        return categories.first { $0.id == categoryID }?.name ?? "Unknown"
    }
    
    func getAccountWithCurrency(for accountID: Int64) -> (Account, Currency)? {
        return accountsWithCurrency.first { $0.0.id == accountID}
    }

    func calculateTotal(for day: String) -> String {
        let transactions = txns_per_day[day] ?? []
        let totalAmount = transactions.reduce(0.0) { $0 + ( $1.transAmount ?? 0.0) }
        return String(format: "%.2f", totalAmount)
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
