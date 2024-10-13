//
//  EnterView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterView: View {
    @State var newTxn: TransactionData = TransactionData()
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss
    
    @State private var accountId: [DataId] = []
    @State private var payees: [PayeeData] = []
    
    var body: some View {
        NavigationStack {
            TransactionEditView(
                accountId: $accountId,
                categories: $viewModel.categories,
                payees: $payees,
                txn: $newTxn
            )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            dismiss()
                            selectedTab = 0
                            newTxn = TransactionData()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            viewModel.addTransaction(txn: &newTxn)
                            dismiss()
                            selectedTab = 0
                            newTxn = TransactionData()
                        }
                        .disabled(!newTxn.isValid)
                    }
                }
        }
        .padding()
        // .navigationBarTitle("Add Transaction", displayMode: .inline)
        .onAppear() {
            loadAccounts()
            viewModel.loadCategories()
            loadPayees()
            // TODO update initial payee (e.g. last used)
            // TODO update category, payee associated?
            
            // database level setting
            let repository = env.infotableRepository
            if let storedDefaultAccount = repository?.getValue(for: InfoKey.defaultAccountID.id, as: DataId.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
    }

    func loadAccounts() {
        let repository = env.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let id = repository?.loadId(from: A.table.order(A.col_name)) ?? []
            DispatchQueue.main.async {
                self.accountId = id
            }
        }
    }

    func loadPayees() {
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = env.payeeRepository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }
}
