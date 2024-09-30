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
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss
    
    @State private var payees: [PayeeData] = []
    @State private var categories: [CategoryData] = []
    @State private var accounts: [AccountData] = []
    
    var body: some View {
        NavigationStack {
            TransactionEditView(txn: $newTxn, payees: $payees, categories: $categories, accounts: $accounts)
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
                            addTransaction(txn: &newTxn)
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
            loadPayees()
            loadCategories()
            loadAccounts()
            // TODO update initial payee (e.g. last used)
            // TODO update category, payee associated?
            
            // database level setting
            let repository = dataManager.infotableRepository
            if let storedDefaultAccount = repository?.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
    }

    func addTransaction(txn: inout TransactionData) {
        // TODO move to a centeriazed place?
        if txn.transCode == .transfer {
            txn.payeeId = 0
        } else {
            txn.toAccountId = 0
        }
        guard let repository = dataManager.transactionRepository else { return }
        if repository.insert(&txn) {
            // id is ready after repo call
        } else {
            // TODO
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
    
    func loadAccounts() {
        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = dataManager.accountRepository?.load() ?? []
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
            }
        }
    }
}
