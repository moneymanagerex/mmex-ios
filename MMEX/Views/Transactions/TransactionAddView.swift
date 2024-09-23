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
    
    @Binding var payees: [PayeeData]
    @Binding var categories: [CategoryData]
    @Binding var accounts: [AccountFull]
    
    var onSave: (inout TransactionData) -> Void
    
    var body: some View {
        NavigationStack {
            TransactionEditView(txn: $newTxn, payees: $payees, categories: $categories, accounts: $accounts)
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
                    }
                }
        }
    }
}

#Preview {
    TransactionAddView(
        newTxn: .constant(TransactionData()),
        isPresentingTransactionAddView: .constant(true),
        payees: .constant(PayeeData.sampleData),
        categories: .constant(CategoryData.sampleData),
        accounts: .constant(AccountFull.sampleFull)
    ) { newTxn in
        // Handle saving in preview
        print("New payee: \(newTxn.id)")
    }}
