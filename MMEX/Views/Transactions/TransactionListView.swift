//
//  CheckingListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @ObservedObject var viewModel: InfotableViewModel
    @State private var txns: [TransactionData] = []
    @State private var newTxn = TransactionData()
    @State private var isPresentingTransactionAddView = false

    @State private var accountId: [Int64] = []  // sorted by name
    @State private var categories: [CategoryData] = []
    @State private var categoryDict: [Int64: CategoryData] = [:] // for lookup
    @State private var payees: [PayeeData] = []
    @State private var payeeDict: [Int64: PayeeData] = [:] // for lookup
    
    var body: some View {
        NavigationStack {
            List(viewModel.txns) { txn in
                NavigationLink(destination: TransactionDetailView(
                    viewModel: viewModel,
                    txn: txn,
                    accountId: $accountId,
                    categories: $categories,
                    payees: $payees
                ) ) {
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
                            Text(getPayeeName(for: txn))
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
            loadAccount()
            loadCategory()
            loadPayee()
            viewModel.loadTransactions()

            // database level setting
            let repository = dataManager.infotableRepository
            if let storedDefaultAccount = repository?.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
        .sheet(isPresented: $isPresentingTransactionAddView) {
            TransactionAddView(
                newTxn: $newTxn,
                isPresentingTransactionAddView: $isPresentingTransactionAddView,
                accountId: $accountId,
                categories: $categories,
                payees: $payees
            ) { newTxn in
                viewModel.addTransaction(txn: &newTxn)
                newTxn = TransactionData()
            }
        }
    }

    func loadAccount() {
        let repository = dataManager.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let id = repository?.loadId(from: A.table.order(A.col_name)) ?? []
            DispatchQueue.main.async {
                self.accountId = id
            }
        }
    }
    
    func loadCategory() {
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

    func loadPayee() {
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
            if let toAccount = dataManager.accountData[txn.toAccountId] {
                return String(format: "> \(toAccount.name)")
            }
        }

        if let payee = self.payeeDict[txn.payeeId] {
            return payee.name
        }

        return "Unknown"
    }
    
    func getCategoryName(for categoryID: Int64) -> String {
        // Find the category with the given ID
        return categories.first { $0.id == categoryID }?.name ?? "Unknown"
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

#Preview {
    TransactionListView(viewModel: InfotableViewModel(dataManager: DataManager()))
        .environmentObject(DataManager())
}
