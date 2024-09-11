//
//  TransactionAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView: View {
    @Binding var newTxn: Transaction
    @Binding var isPresentingTransactionAddView: Bool
    
    var onSave: (inout Transaction) -> Void
    
    var body: some View {
        NavigationStack {
            TransactionEditView(txn: $newTxn)
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
    TransactionAddView(newTxn: .constant(Transaction.empty), isPresentingTransactionAddView: .constant(true)) { newTxn in
        // Handle saving in preview
        print("New payee: \(newTxn.id)")
    }}
