//
//  AssetAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetAddView: View {
    @Binding var newAsset: AssetData
    @Binding var isPresentingAssetAddView: Bool

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var onSave: (inout AssetData) -> Void

    var body: some View {
        NavigationStack {
            AssetEditView(asset: $newAsset)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingAssetAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if validateAsset() {
                                isPresentingAssetAddView = false
                                onSave(&newAsset)
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

    func validateAsset() -> Bool {
        if newAsset.name.isEmpty {
            alertMessage = "Asset name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview {
    AssetAddView(
        newAsset: .constant(AssetData()),
        isPresentingAssetAddView: .constant(true)
    ) { newAsset in
        // Handle saving in preview
        print("New asset: \(newAsset.name)")
    }
}