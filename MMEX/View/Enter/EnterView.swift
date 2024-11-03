//
//  EnterView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterView: View {
    @State var newTxn: TransactionData = TransactionData()
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss
    
    @State private var accountId: [DataId] = []
    
    var body: some View {
        NavigationStack {
            TransactionEditView(
                vm: vm,
                viewModel: viewModel,
                accountId: $accountId,
                categories: $viewModel.categories,
                payees: $viewModel.payees,
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
            viewModel.loadPayees()
            
            // database level setting
            let repository = InfotableRepository(env)
            if let storedDefaultAccount = repository?.getValue(for: InfoKey.defaultAccountID.id, as: DataId.self) {
                newTxn.accountId = storedDefaultAccount
            }
        }
    }

    func loadAccounts() {
        let repository = AccountRepository(env)
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let id = repository?.loadId(from: A.table.order(A.col_name)) ?? []
            DispatchQueue.main.async {
                self.accountId = id
            }
        }
    }
}
