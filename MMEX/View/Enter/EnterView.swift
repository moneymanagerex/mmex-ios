//
//  EnterView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var selectedTab: Int

    @State var newTxn: TransactionData = TransactionData()
    
    var body: some View {
        NavigationStack {
            EnterFormView(
                vm: vm,
                txn: $newTxn
            )
        }
        .padding()
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
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
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
            } else if env.pref.reuseLastPayee == .boolTrue, !newTxn.accountId.isVoid {
                loadLatestTxn(for: newTxn.accountId)
            }
        }

        if newTxn.id.isVoid {
            newTxn.status = env.pref.defaultStatus
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

#Preview {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    let viewModel = TransactionViewModel(env: env)
    NavigationView {
        EnterView(
            vm: vm,
            viewModel: viewModel,
            selectedTab: .constant(0)
        )
    }
    .environmentObject(env)
}
