//
//  StockAddView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockAddView: View {
    @Binding var allAccountName: [(Int64, String)] // sorted by name
    @Binding var newStock: StockData
    @Binding var isPresentingStockAddView: Bool

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var onSave: (inout StockData) -> Void

    var body: some View {
        NavigationStack {
            StockEditView(
                allAccountName: $allAccountName,
                stock: $newStock
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        isPresentingStockAddView = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if validateStock() {
                            isPresentingStockAddView = false
                            onSave(&newStock)
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

        // Add more validation logic here if needed (e.g., account selection)
        return true
    }
}

#Preview {
    StockAddView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        newStock: .constant(StockData()),
        isPresentingStockAddView: .constant(true)
    ) { newStock in
        // Handle saving in preview
        print("New stock: \(newStock.name)")
    }
}
