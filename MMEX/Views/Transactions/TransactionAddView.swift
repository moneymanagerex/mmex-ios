//
//  TransactionAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView: View {
    @Binding var newTxn: TransactionData
    @Binding var isPresentingTransactionAddView: Bool

    @Binding var accountId: [Int64]
    @Binding var categories: [CategoryData]
    @Binding var payees: [PayeeData]

    var onSave: (inout TransactionData) -> Void
    
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

#Preview {
    TransactionAddView(
        newTxn: .constant(TransactionData()),
        isPresentingTransactionAddView: .constant(true),
        accountId: .constant(AccountData.sampleData.map { account in
            account.id
        } ),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData)
    ) { newTxn in
        // Handle saving in preview
        print("New payee: \(newTxn.id)")
    }}
