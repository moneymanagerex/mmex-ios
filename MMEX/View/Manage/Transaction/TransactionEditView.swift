//
//  TransactionEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var isPresented: Bool
    @Binding var txn: TransactionData
    @Binding var editingTxn: TransactionData

    @State private var focus = false

    var body: some View {
        EnterFormView(
            focus: $focus,
            txn: $editingTxn
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
                    txn = editingTxn
                    if (vm.updateTransaction(&txn) == false) {
                        // TODO
                    }
                }
                .disabled(!editingTxn.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
    }
}
