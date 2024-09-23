//
//  CheckingListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView: View {
    let databaseURL: URL
    @State private var txns: [TransactionData] = []
    @State private var newTxn = TransactionData()
    @State private var isPresentingTransactionAddView = false
    
    @State private var payees: [PayeeData] = []
    @State private var categories: [CategoryData] = []
    @State private var accounts: [AccountFull] = []

    private var repository: TransactionRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getTransactionRepository()
    }
    
    var body: some View {
        NavigationStack {
            List(txns) { txn in
                NavigationLink(destination: TransactionDetailView(txn: txn, databaseURL: databaseURL, payees: $payees, categories: $categories, accounts: $accounts)) {
                    HStack {
                        // Left column: Date (truncated to day)
                        Text(formatDate(from: txn.transDate))
                            .frame(width: 90, alignment: .leading)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)

                        // Spacer between date and middle section
                        Spacer(minLength: 5)

                        // Middle column: Payee name and Category icon (or ID)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getPayeeName(for: txn.payeeId))
                                .font(.system(size: 16))
                                .lineLimit(1) // Prevent wrapping
                            Text("\(txn.transCode.id)") // Replace with transcode name if available
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, alignment: .leading)

                        // Spacer between middle and right section
                        Spacer()

                        // Right column: Amount
                        Text(String(format: "%.2f", txn.transAmount))
                            .frame(alignment: .trailing)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(txn.transAmount >= 0 ? .green : .red)
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingTransactionAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Transaction")
            }
        }
        .onAppear {
            loadTransactions()
            loadPayees()
            loadCategories()
            loadAccounts()
            
            // database level setting
            let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
            if let storedDefaultAccount = repository.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
        .sheet(isPresented: $isPresentingTransactionAddView) {
            TransactionAddView(newTxn: $newTxn, isPresentingTransactionAddView: $isPresentingTransactionAddView, payees: $payees, categories: $categories, accounts: $accounts) { newTxn in
                addTransaction(txn: &newTxn)
                newTxn = TransactionData()
            }
        }
    }
    
    func loadTransactions() {
        print("Loading txn in TransactionListView...")
        
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = repository.load()
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.txns = loadTransactions
            }
        }
    }
    
    func loadPayees() {
        let repository = DataManager(databaseURL: self.databaseURL).getPayeeRepository()

        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository.load()
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }
    
    func loadCategories() {
        let repository = DataManager(databaseURL: self.databaseURL).getCategoryRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository.load()
            
            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }
    
    func loadAccounts() {
        let repository = DataManager(databaseURL: self.databaseURL).getAccountRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository.loadWithCurrency()
            
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
            }
        }
    }
    
    func getPayeeName(for payeeID: Int64) -> String {
        // Find the payee with the given ID
        return payees.first { $0.id == payeeID }?.name ?? "Unknown"
    }
    
    func getCategoryName(for categoryID: Int64) -> String {
        // Find the category with the given ID
        return categories.first { $0.id == categoryID }?.name ?? "Unknown"
    }
    
    func addTransaction(txn: inout TransactionData) {
        // TODO
        if self.repository.insert(&txn) {
            self.txns.append(txn) // id is ready after repo call
        } else {
            // TODO
        }
    }
    
    // Helper function to format the date, truncating to day
    func formatDate(from isoDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Assuming ISO-8601 format
        if let date = formatter.date(from: isoDate) {
            formatter.dateFormat = "yyyy-MM-dd" // Truncate to day
            return formatter.string(from: date)
        }
        return isoDate
    }
}
