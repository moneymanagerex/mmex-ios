//
//  TransactionCreateView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionCreateView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var isPresented: Bool
    @Binding var newTxn: TransactionData
    var onSave: (inout TransactionData) -> Void

    @State private var focus = false

    var body: some View {
        EnterFormView(
            focus: $focus,
            txn: $newTxn
        )

        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    isPresented = false
                    onSave(&newTxn)
                }
                .disabled(!newTxn.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
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
