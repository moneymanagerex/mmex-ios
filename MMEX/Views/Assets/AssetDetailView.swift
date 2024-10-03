//
//  AssetDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetDetailView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @Binding var allCurrencyName: [(Int64, String)] // Bind to the list of available currencies
    @State var asset: AssetData

    @State private var editingAsset = AssetData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    @State private var isExporting = false
    @State private var exportURL: URL?

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        List {
            let currency = env.currencyCache[asset.currencyId]
            let formatter = currency?.formatter
            Section(header: Text("Asset Name")) {
                Text("\(asset.name)")
            }

            Section(header: Text("Type")) {
                Text(asset.type.rawValue)
            }

            Section(header: Text("Status")) {
                Text(asset.status.rawValue)
            }

            Section(header: Text("Start Date")) {
                Text(asset.startDate)
            }

            Section(header: Text("Value")) {
                Text("\(asset.value.formatted(by: formatter))")
            }

            Section(header: Text("Change")) {
                Text(asset.change.rawValue)
            }

            Section(header: Text("Change Mode")) {
                Text(asset.changeMode.rawValue)
            }

            Section(header: Text("Notes")) {
                Text(asset.notes)
            }

            Button("Delete Asset") {
                // Implement delete functionality
            }
        }
        .textSelection(.enabled)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditView = true
                    editingAsset = asset
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
                    asset: $editingAsset
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
                                isPresentingEditView = false
                                asset = editingAsset
                                saveChanges()
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
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func saveChanges() {
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
        if editingAsset.name.isEmpty {
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
