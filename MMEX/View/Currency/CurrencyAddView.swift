//
//  CurrencyAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyAddView: View {
    @Binding var newCurrency: CurrencyData
    @Binding var isPresentingAddView: Bool
    var onSave: (inout CurrencyData) -> Void

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            CurrencyEditView(
                currency: $newCurrency,
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
                        if validateCurrency() {
                            onSave(&newCurrency)
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
    
    func validateCurrency() -> Bool {
        if newCurrency.name.isEmpty {
            alertMessage = "Currency name cannot be empty."
            return false
        }
        else if newCurrency.symbol.isEmpty {
            alertMessage = "Currency symbol cannot be empty."
            return false
        }

        // TODO: Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

/*
#Preview {
    CurrencyAddView(
        newCurrency: .constant(CurrencyData()),
        isPresentingAddView: .constant(true)
    ) { newCurrency in
        // Handle saving in preview
        log.info("New currency: \(newCurrency.name)")
    }
}
*/
