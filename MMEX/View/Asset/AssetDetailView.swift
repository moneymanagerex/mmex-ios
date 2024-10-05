//
//  AssetDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetDetailView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @Binding var allCurrencyName: [(Int64, String)] // Bind to the list of available currencies
    @State var asset: AssetData

    @State private var editAsset = AssetData()
    @State private var isPresentingEditView = false
    @State private var isExporting = false
    @State private var exportURL: URL?

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        AssetEditView(
            allCurrencyName: $allCurrencyName,
            asset: $asset,
            edit: false
        ) { () in
            deleteAsset()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    editAsset = asset
                    isPresentingEditView = true
                }
                // Export button for pasteboard and external storage
                Menu {
                    Button("Copy to Clipboard") {
                        asset.copyToPasteboard()
                    }
                    Button("Export as JSON File") {
                        isExporting = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                AssetEditView(
                    allCurrencyName: $allCurrencyName,
                    asset: $editAsset,
                    edit: true
                )
                .navigationTitle(asset.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingEditView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if validateAsset() {
                                asset = editAsset
                                updateAsset()
                                isPresentingEditView = false
                            } else {
                                isShowingAlert = true
                            }
                        }
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: asset),
            contentType: .json,
            defaultFilename: "\(asset.name)_Asset"
        ) { result in
            switch result {
            case .success(let url):
                log.info("File saved to: \(url)")
            case .failure(let error):
                log.error("Error exporting file: \(error)")
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Validation Error"),
                message: Text(alertMessage), dismissButton: .default(Text("OK"))
            )
        }
    }

    func updateAsset() {
        let repository = env.assetRepository // pass URL here
        if repository?.update(asset) == true {
            // TODO
        } else {
            // TODO update failure
        }
    }

    func deleteAsset(){
        let repository = env.assetRepository // pass URL here
        if repository?.delete(asset) == true {
            // Dismiss the AssetDetailView and go back to the previous view
            presentationMode.wrappedValue.dismiss()
        } else {
            // TODO
            // handle deletion failure
        }
    }

    func validateAsset() -> Bool {
        if editAsset.name.isEmpty {
            alertMessage = "Asset name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview {
    AssetDetailView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        asset: AssetData.sampleData[0]
    )
    .environmentObject(EnvironmentManager.sampleData)
}
