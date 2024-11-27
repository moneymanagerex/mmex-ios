//
//  TransactionAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var newTxn: TransactionData
    @Binding var isPresentingTransactionAddView: Bool

    var onSave: (inout TransactionData) -> Void
    
    var body: some View {
        EnterFormView(
            txn: $newTxn
        )
    
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresentingTransactionAddView = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    isPresentingTransactionAddView = false
                    onSave(&newTxn)
                }
                .disabled(!newTxn.isValid)
            }
        }
    }
}

/*
#Preview {
    TransactionAddView(
        newTxn: .constant(TransactionData()),
        isPresentingTransactionAddView: .constant(true)
    )
    { newTxn in
        log.info("New transaction: #\(newTxn.id.value)")
    }
    .environmentObject(EnvironmentManager())
}
*/
