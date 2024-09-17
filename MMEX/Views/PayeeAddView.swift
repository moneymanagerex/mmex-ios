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
    @Binding var categories: [Category]
    
    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var onSave: (inout Payee) -> Void
    
    var body: some View {
        NavigationStack {
            PayeeEditView(payee: $newPayee, categories: $categories)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingPayeeAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if validatePayee() {
                                isPresentingPayeeAddView = false
                                onSave(&newPayee)
                            } else {
                                isShowingAlert = true
                            }
                        }
                    }
                }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func validatePayee() -> Bool {
        if newPayee.name.isEmpty {
            alertMessage = "Payee name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview {
    PayeeAddView(newPayee: .constant(Payee.empty), isPresentingPayeeAddView: .constant(true), categories: .constant(Category.sampleData)) { newPayee in
        // Handle saving in preview
        print("New payee: \(newPayee.name)")
    }
}
