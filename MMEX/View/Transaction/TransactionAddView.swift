//
//  TransactionAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView: View {
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var accountId: [DataId]
    @Binding var categories: [CategoryData]
    @Binding var payees: [PayeeData]
    @Binding var newTxn: TransactionData
    @Binding var isPresentingTransactionAddView: Bool

    var onSave: (inout TransactionData) -> Void
    
    var body: some View {
        NavigationStack {
            TransactionEditView(
                vm: vm,
                viewModel: viewModel,
                accountId: $accountId,
                categories: $categories,
                payees: $payees,
                txn: $newTxn
            )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingTransactionAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingTransactionAddView = false
                            onSave(&newTxn)
                        }
                        .disabled(!newTxn.isValid)
                    }
                }
        }
    }
}
/*
#Preview {
    TransactionAddView(
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        newTxn: .constant(TransactionData()),
        isPresentingTransactionAddView: .constant(true)
    )
    { newTxn in
        // Handle saving in preview
        log.info("New transaction: #\(newTxn.id.value)")
    }
    .environmentObject(EnvironmentManager())
}
*/
