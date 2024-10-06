//
//  StockDetailView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockDetailView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @Binding var allAccountName: [(Int64, String)] // sorted by name
    @State var stock: StockData

    @State private var editStock = StockData()
    @State private var isPresentingEditView = false
    @State private var isExporting = false
    @State private var exportURL: URL?

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        StockEditView(
            allAccountName: $allAccountName,
            stock: $stock,
            edit: false
        ) { () in
            deleteStock()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    editStock = stock
                    isPresentingEditView = true
                }
                // Export button for pasteboard and external storage
                Menu {
                    Button("Copy to Clipboard") {
                        stock.copyToPasteboard()
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
                StockEditView(
                    allAccountName: $allAccountName,
                    stock: $editStock,
                    edit: true
                )
                .navigationTitle(stock.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingEditView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if validateStock() {
                                stock = editStock
                                updateStock()
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
            document: ExportableEntityDocument(entity: stock),
            contentType: .json,
            defaultFilename: "\(stock.name)_Stock"
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
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func updateStock() {
        let repository = env.stockRepository // pass URL here
        if repository?.update(stock) == true {
            // TODO
        } else {
            // TODO update failure
        }
    }

    func deleteStock(){
        let repository = env.stockRepository // pass URL here
        if repository?.delete(stock) == true {
            // Dismiss the StockDetailView and go back to the previous view
            presentationMode.wrappedValue.dismiss()
        } else {
            // TODO
            // handle deletion failure
        }
    }

    func validateStock() -> Bool {
        if editStock.name.isEmpty {
            alertMessage = "Stock name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview(StockData.sampleData[0].name) {
    StockDetailView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: StockData.sampleData[0]
    )
    .environmentObject(EnvironmentManager.sampleData)
}
