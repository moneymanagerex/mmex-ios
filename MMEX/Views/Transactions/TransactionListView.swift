//
//  CheckingListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @ObservedObject var viewModel: InfotableViewModel
    @State private var txns: [TransactionData] = []
    @State private var newTxn = TransactionData()
    @State private var isPresentingTransactionAddView = false

    var body: some View {
        NavigationStack {
            if viewModel.resetCurrentHeader() {} // TODO: better reset?
            List($viewModel.txns) { $txn in
                if (viewModel.newDateHeader(transDate: txn.transDate)) {
                    Text(viewModel.currentHeader)
                }
                NavigationLink(destination: TransactionDetailView(
                    viewModel: viewModel,
                    accountId: $viewModel.accountId,
                    categories: $viewModel.categories,
                    payees: $viewModel.payees,
                    txn: $txn
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
            viewModel.loadAccounts()
            viewModel.loadCategories()
            viewModel.loadPayees()
            viewModel.loadTransactions()

            // database level setting
            let repository = env.infotableRepository
            if let storedDefaultAccount = repository?.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
        .sheet(isPresented: $isPresentingTransactionAddView) {
            TransactionAddView(
                accountId: $viewModel.accountId,
                categories: $viewModel.categories,
                payees: $viewModel.payees,
                newTxn: $newTxn,
                isPresentingTransactionAddView: $isPresentingTransactionAddView
            ) { newTxn in
                viewModel.addTransaction(txn: &newTxn)
                newTxn = TransactionData()
            }
        }
    }

    // TODO pre-join via SQL?
    func getPayeeName(for txn: TransactionData) -> String {
        // Find the payee with the given ID
        if txn.transCode == .transfer {
            if let toAccount = env.accountCache[txn.toAccountId] {
                return String(format: "> \(toAccount.name)")
            }
        }

        return viewModel.getPayeeName(for: txn.payeeId)
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
    TransactionListView(
        viewModel: InfotableViewModel(env: EnvironmentManager.sampleData)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
