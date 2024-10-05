//
//  PayeeAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct PayeeAddView: View {
    @Binding var categories: [CategoryData]
    @Binding var newPayee: PayeeData
    @Binding var isPresentingAddView: Bool
    var onSave: (inout PayeeData) -> Void

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            PayeeEditView(
                categories: $categories,
                payee: $newPayee,
                edit: true
            )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if validatePayee() {
                                onSave(&newPayee)
                                isPresentingAddView = false
                            } else {
                                isShowingAlert = true
                            }
                        }
                    }
                }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Validation Error"),
                message: Text(alertMessage), dismissButton: .default(Text("OK"))
            )
        }
    }

    func validatePayee() -> Bool {
        if newPayee.name.isEmpty {
            alertMessage = "Payee name cannot be empty."
            return false
        }

        // TODO: Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

/*
#Preview {
    PayeeAddView(
        newPayee: .constant(PayeeData()),
        isPresentingAddView: .constant(true),
        categories: .constant(CategoryData.sampleData)
    ) { newPayee in
        // Handle saving in preview
        log.info("New payee: \(newPayee.name)")
    }
}
*/
