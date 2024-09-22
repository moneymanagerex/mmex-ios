//
//  TransactionAddView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView2: View {    
    @State var newTxn: Transaction = Transaction.empty
    let databaseURL: URL
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss
    
    @State private var payees: [Payee] = []
    @State private var categories: [Category] = []
    @State private var accounts: [Account] = []
    
    var body: some View {
        NavigationStack {
            TransactionEditView(txn: $newTxn, payees: $payees, categories: $categories, accounts: $accounts)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            dismiss()
                            selectedTab = 0
                            newTxn = Transaction.empty
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addTransaction(txn: &newTxn)
                            dismiss()
                            selectedTab = 0
                            newTxn = Transaction.empty
                        }
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
            let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
            if let storedDefaultAccount = repository.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
    }

    func addTransaction(txn: inout Transaction) {
        let repository = DataManager(databaseURL: self.databaseURL).getTransactionRepository()
        if repository.addTransaction(txn:&txn) {
            // id is ready after repo call
        } else {
            // TODO
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
}
