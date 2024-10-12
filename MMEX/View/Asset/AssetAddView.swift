//
//  AssetAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetAddView: View {
    @Binding var allCurrencyName: [(DataId, String)] // Bind to the list of available currencies
    @Binding var newAsset: AssetData
    @Binding var isPresentingAddView: Bool
    var onSave: (inout AssetData) -> Void

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            AssetEditView(
                allCurrencyName: $allCurrencyName,
                asset: $newAsset,
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
                        if validateAsset() {
                            onSave(&newAsset)
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

    func validateAsset() -> Bool {
        if newAsset.name.isEmpty {
            alertMessage = "Asset name cannot be empty."
            return false
        }

        // TODO: Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

/*
#Preview {
    AssetAddView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        newAsset: .constant(AssetData()),
        isPresentingAddView: .constant(true)
    ) { newAsset in
        // Handle saving in preview
        log.info("New asset: \(newAsset.name)")
    }
}
*/
