//
//  EnterView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var selectedTab: Int

    @State private var focus = false
    @State var newTxn: TransactionData = TransactionData()
    
    var body: some View {
        EnterFormView(
            focus: $focus,
            txn: $newTxn
        )
        .padding()

        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                    selectedTab = Preference.selectedTab
                    newTxn = TransactionData()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    vm.addTransaction(txn: &newTxn)
                    dismiss()
                    selectedTab = Preference.selectedTab
                    newTxn = TransactionData()
                }
                .disabled(!newTxn.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
        // .navigationBarTitle("Add Transaction", displayMode: .inline)
        .task {
            await load()
        }
    }

    private func load() async {
        log.trace("DEBUG: EnterView.load(main=\(Thread.isMainThread))")
        await vm.loadEnterList(pref)

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
            } else if pref.enter.reuseLastPayee == .boolTrue, !newTxn.accountId.isVoid {
                loadLatestTxn(for: newTxn.accountId)
            }
        }

        if newTxn.id.isVoid {
            newTxn.status = pref.enter.defaultStatus
        }
    }

    func loadLatestTxn(for accountId: DataId) {
        let repository = TransactionRepository(vm.db)
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
    let pref = Preference()
    let vm = ViewModel.sampleData
    NavigationView {
        EnterView(
            selectedTab: .constant(0)
        )
    }
    .environmentObject(pref)
    .environmentObject(vm)
}
