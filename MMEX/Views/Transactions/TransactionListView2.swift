//
//  TransactionListView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView2: View {
    let databaseURL: URL
    @ObservedObject var viewModel: InfotableViewModel

    @State private var payees: [PayeeData] = []
    @State private var payeeDict: [Int64: PayeeData] = [:] // for lookup
    @State private var categories: [CategoryData] = []
    @State private var categoryDict: [Int64: CategoryData] = [:] // for lookup
    @State private var accounts: [AccountWithCurrency] = []
    @State private var accountDict: [Int64: AccountWithCurrency] = [: ] // for lookup
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.viewModel = InfotableViewModel(databaseURL: databaseURL) // TODO shared instance with Settings?
    }
    
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
                            NavigationLink(destination: TransactionDetailView(txn: txn, databaseURL: databaseURL, payees: $payees, categories: $categories, accounts: $accounts)) {
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
                                        Text(getPayeeName(for: txn.payeeId)) // Payee name
                                            .font(.system(size: 16))
                                            .lineLimit(1) // Prevent wrapping
                                        Text(formatTime(txn.transDate)) // Show time in hh:mm a
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 100, alignment: .leading) // Widen middle column, ensuring enough space

                                    Spacer() // To push the amount to the right side

                                    if let currency = self.accountDict[txn.accountId]?.currency {
                                        // Right column (Transaction Amount)
                                        VStack {
                                            // amount in account currency
                                            Text(currency.format(amount: txn.transAmount))
                                                .frame(alignment: .trailing) // Ensure it's aligned to the right
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                                            // amount in base currency
                                            if let baseCurrency = viewModel.baseCurrency {
                                                Text(baseCurrency.format(amount: txn.transAmount * currency.baseConvRate))
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
                                // TODO SFSymbol
                                if let accountSymbol = AccountData.accountTypeToSFSymbol[account.data.type.name] {
                                    Image(systemName: accountSymbol)
                                        .frame(width: 5, alignment: .leading) // Adjust width as needed
                                        .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                        .foregroundColor(.blue) // Customize icon style
                                }
                                Text(account.data.name)
                            }.tag(account.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Makes it appear as a dropdown
                }
            }
        }
        .onAppear {
            viewModel.loadTransactions()
            loadPayees()
            loadCategories()
            loadAccounts()
        }
    }

    func loadPayees() {
        let repository = DataManager(databaseURL: self.databaseURL).getPayeeRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository.load()
            
            DispatchQueue.main.async {
                self.payees = loadedPayees
                self.payeeDict = Dictionary(uniqueKeysWithValues: payees.map { ($0.id, $0) })
            }
        }
    }
    
    func loadCategories() {
        let repository = DataManager(databaseURL: self.databaseURL).getCategoryRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository.load()
            
            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
            }
        }
    }
    
    func loadAccounts() {
        let repository = DataManager(databaseURL: self.databaseURL).getAccountRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository.loadWithCurrency()
            
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
                self.accountDict = Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) })
            }
        }
    }

    // TODO pre-join via SQL?
    func getPayeeName(for payeeID: Int64) -> String {
        // Find the payee with the given ID
        if let payee = self.payeeDict[payeeID] {
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
