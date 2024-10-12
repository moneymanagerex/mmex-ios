//
//  StockAddView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockAddView: View {
    @Binding var allAccountName: [(DataId, String)] // sorted by name
    @Binding var newStock: StockData
    @Binding var isPresentingAddView: Bool
    var onSave: (inout StockData) -> Void

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            StockEditView(
                allAccountName: $allAccountName,
                stock: $newStock,
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
                        if validateStock() {
                            onSave(&newStock)
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
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func validateStock() -> Bool {
        if newStock.name.isEmpty {
            alertMessage = "Stock name cannot be empty."
            return false
        }

        // TODO: Add more validation logic here if needed (e.g., account selection)
        return true
    }
}

/*
#Preview {
    StockAddView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        newStock: .constant(StockData()),
        isPresentingAddView: .constant(true)
    ) { newStock in
        // Handle saving in preview
        log.trace("DEBUG: New stock: \(newStock.name)")
    }
}
*/
