//
//  EnterView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss

    // app level setting
    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus = TransactionStatus.defaultValue

    @State var newTxn: TransactionData = TransactionData()
    
    var body: some View {
        NavigationStack {
            EnterEditView(
                vm: vm,
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
        .task {
            await load()
        }
    }

    private func load() async {
        log.trace("DEBUG: EnterView.load(main=\(Thread.isMainThread))")
        await vm.loadEnterList()

        if newTxn.accountId.isVoid {
            if let defaultAccountId = vm.infotableList.defaultAccountId.readyValue {
                newTxn.accountId = defaultAccountId
            } else if let accountOrder = vm.accountList.order.readyValue, accountOrder.count == 1 {
                newTxn.accountId = accountOrder[0]
            }
        }

        if newTxn.categId.isVoid {
            if let categoryOrder = vm.categoryList.order.readyValue, categoryOrder.count == 1 {
                newTxn.categId = categoryOrder[0]
            }
        }

        if newTxn.payeeId.isVoid {
            if let payeeOrder = vm.payeeList.order.readyValue, payeeOrder.count == 1 {
                newTxn.payeeId = payeeOrder[0]
            } else if defaultPayeeSetting == DefaultPayeeSetting.lastUsed, !newTxn.accountId.isVoid {
                loadLatestTxn(for: newTxn.accountId)
            }
        }

        if newTxn.id.isVoid {
            newTxn.status = defaultStatus
        }
    }

    func loadLatestTxn(for accountId: DataId) {
        let repository = TransactionRepository(env)
        if let latestTxn = repository?.latest(accountID: accountId).toOptional() ?? repository?.latest().toOptional() {
            // Update UI on the main thread
            DispatchQueue.main.async {
                if newTxn.payeeId.isVoid {
                    newTxn.payeeId = latestTxn.payeeId
                    // txn.categId = latestTxn.categId
                }
            }
        }
    }
}
