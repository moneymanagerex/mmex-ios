//
//  TransactionListView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView2: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var viewModel: InfotableViewModel

    @State private var accountId: [Int64] = []  // sorted by name
    @State private var accounts: [AccountData] = []
    @State private var accountDict: [Int64: AccountData] = [: ] // for lookup
    @State private var categories: [CategoryData] = []
    @State private var categoryDict: [Int64: CategoryData] = [:] // for lookup
    @State private var payees: [PayeeData] = []
    @State private var payeeDict: [Int64: PayeeData] = [:] // for lookup
    
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
                            transactionView(txn)
                        }
                    }
                }
            }
            .toolbar {
                // Search box on the top-left corner
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "magnifyingglass") // Search icon
                        // TODO search by notes
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Select Account", selection: $viewModel.defaultAccountId) {
                        ForEach(self.accounts) { account in
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
                }
            }
        }
        .onAppear {
            viewModel.loadTransactions()
            loadAccounts()
            loadCategories()
            loadPayees()
        }
    }

    func transactionView(_ txn: TransactionData) -> some View {
        NavigationLink(destination: TransactionDetailView(
            txn: txn,
            accountId: $accountId,
            categories: $categories,
            payees: $payees
        ) ) {
            HStack {
                // Left column (Category Icon or Category Name)
                if let categorySymbol = CategoryData.categoryToSFSymbol[getCategoryName(for: txn.categId)] {
                    Image(systemName: categorySymbol)
                        .frame(width: 50, alignment: .leading) // Adjust width as needed
                        .font(.system(size: 16, weight: .bold)) // Customize size and weight as needed
                        .foregroundColor(.blue) // Customize icon style
                } else {
                    Text(getCategoryName(for: txn.categId)) // Fallback to category name if symbol is not found
                        .frame(width: 50, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }

                // Middle column (Payee Name & Time)
                VStack(alignment: .leading, spacing: 4) {
                    Text(getPayeeName(for: txn)) // Payee name
                        .font(.system(size: 16))
                        .lineLimit(1) // Prevent wrapping
                    Text(formatTime(txn.transDate)) // Show time in hh:mm a
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(width: 100, alignment: .leading) // Widen middle column, ensuring enough space

                Spacer() // To push the amount to the right side

                if let currencyId = self.accountDict[txn.accountId]?.currencyId,
                   let currencyFormatter = dataManager.currencyCache[currencyId]?.formatter
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
                           let baseConvRate = dataManager.currencyCache[currencyId]?.baseConvRate
                        {
                            Text((txn.transAmount * baseConvRate)
                                .formatted(by: dataManager.currencyCache[baseCurrencyId]?.formatter)
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
    
    func loadAccounts() {
        let repository = dataManager.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let id = repository?.loadId(from: A.table.order(A.col_name)) ?? []
            let loadedAccounts = repository?.load() ?? []
            let loadedAccountDict = Dictionary(uniqueKeysWithValues: loadedAccounts.map { ($0.id, $0) })
            DispatchQueue.main.async {
                self.accountId = id
                self.accounts = loadedAccounts
                self.accountDict = loadedAccountDict
            }
        }
    }
    
    func loadCategories() {
        let repository = dataManager.categoryRepository
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository?.load() ?? []
            let loadedCategoryDict = Dictionary(uniqueKeysWithValues: loadedCategories.map { ($0.id, $0) })
            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.categoryDict = loadedCategoryDict
            }
        }
    }

    func loadPayees() {
        let repository = dataManager.payeeRepository

        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository?.load() ?? []
            let loadedPayeeDict = Dictionary(uniqueKeysWithValues: loadedPayees.map { ($0.id, $0) })

            DispatchQueue.main.async {
                self.payees = loadedPayees
                self.payeeDict = loadedPayeeDict
            }
        }
    }

    // TODO pre-join via SQL?
    func getPayeeName(for txn: TransactionData) -> String {
        // Find the payee with the given ID
        if txn.transCode == .transfer {
            if viewModel.defaultAccountId == txn.accountId {
                if let toAccount = self.accountDict[txn.toAccountId] {
                    return String(format: "> \(toAccount.name)")
                }
            } else {
                if let fromAccount = self.accountDict[txn.accountId] {
                    return String(format: "< \(fromAccount.name)")
                }
            }
        }

        if let payee = self.payeeDict[txn.payeeId] {
            return payee.name
        }

        return "Unknown"
    }
    
    // TODO pre-join via SQL?
    func getCategoryName(for categoryID: Int64) -> String {
        // Find the category with the given ID
        if let category = self.categoryDict[categoryID] {
            return category.name
        } 
        return "Unknown"
    }

    func calculateTotal(for day: String) -> String {
        let transactions = viewModel.txns_per_day[day] ?? []
        // TODO convert and format via viewModel.baseCurrency
        let totalAmount = transactions.reduce(0.0) { $0 + $1.transAmount }
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
