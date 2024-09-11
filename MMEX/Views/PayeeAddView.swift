//
//  PayeeAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct PayeeAddView: View {
    @Binding var newPayee: Payee
    @Binding var isPresentingPayeeAddView: Bool
    
    var onSave: (inout Payee) -> Void
    
    var body: some View {
        NavigationStack {
            PayeeEditView(payee: $newPayee)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingPayeeAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingPayeeAddView = false
                            onSave(&newPayee)
                        }
                    }
                }
        }
    }
}

#Preview {
    PayeeAddView(newPayee: .constant(Payee.empty), isPresentingPayeeAddView: .constant(true)) { newPayee in
        // Handle saving in preview
        print("New payee: \(newPayee.name)")
    }
}
