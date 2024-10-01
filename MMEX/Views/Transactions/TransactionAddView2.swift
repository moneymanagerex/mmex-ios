//
//  TransactionAddView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView2: View {    
    @State var newTxn: TransactionData = TransactionData()
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @ObservedObject var viewModel: InfotableViewModel
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss
    
    @State private var accountId: [Int64] = []
    @State private var categories: [CategoryData] = []
    @State private var payees: [PayeeData] = []
    
    var body: some View {
        NavigationStack {
            TransactionEditView(
                txn: $newTxn,
                accountId: $accountId,
                categories: $categories,
                payees: $payees
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
            loadCategories()
            loadPayees()
            // TODO update initial payee (e.g. last used)
            // TODO update category, payee associated?
            
            // database level setting
            let repository = dataManager.infotableRepository
            if let storedDefaultAccount = repository?.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
    }

    func loadAccounts() {
        let repository = dataManager.accountRepository
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
            let loadedPayees = dataManager.payeeRepository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }
    
    func loadCategories() {
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = dataManager.categoryRepository?.load() ?? []
            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }
}
