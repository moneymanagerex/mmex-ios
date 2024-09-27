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
    @State private var accounts: [AccountWithCurrency] = []
    
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
                        .disabled(!isTransactionValid())
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

    func isTransactionValid() -> Bool {
        return newTxn.payeeId > 0 && newTxn.categId > 0
    }

    func addTransaction(txn: inout TransactionData) {
        let repository = dataManager.transactionRepository
        if repository?.insert(&txn) == true {
            // id is ready after repo call
        } else {
            // TODO
        }
    }
    
    func loadPayees() {
        let repository = dataManager.payeeRepository

        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository?.load() ?? []
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }
    
    func loadCategories() {
        let repository = dataManager.categoryRepository

        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository?.load() ?? []
            
            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }
    
    func loadAccounts() {
        let repository = dataManager.accountRepository

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository?.loadWithCurrency() ?? []
            
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
            }
        }
    }
}
