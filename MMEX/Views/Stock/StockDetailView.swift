//
//  StockDetailView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockDetailView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @Binding var allAccountName: [(Int64, String)] // sorted by name
    @State var stock: StockData

    @State private var editingStock = StockData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    @State private var isExporting = false
    @State private var exportURL: URL?

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        List {
            let account = env.accountCache[stock.accountId]
            let currency = account != nil ? env.currencyCache[account!.currencyId] : nil
            let formatter = currency?.formatter
            Section(header: Text("Stock Name")) {
                Text("\(stock.name)")
            }

            Section(header: Text("Symbol")) {
                Text(stock.symbol)
            }

            Section(header: Text("Account")) {
                Text(account?.name ?? "")
            }

            Section(header: Text("Number of Shares")) {
                Text("\(stock.numShares)")
            }

            Section(header: Text("Purchase Date")) {
                Text(stock.purchaseDate)
            }

            Section(header: Text("Purchase Price")) {
                Text("\(stock.purchasePrice.formatted(by: formatter))")
            }

            Section(header: Text("Current Price")) {
                Text("\(stock.currentPrice.formatted(by: formatter))")
            }

            Section(header: Text("Value")) {
                Text("\(stock.value.formatted(by: formatter))")
            }

            Section(header: Text("Commisison")) {
                Text("\(stock.commisison.formatted(by: formatter))")
            }

            Section(header: Text("Notes")) {
                Text(stock.notes)
            }

            Button("Delete Stock") {
                // Implement delete functionality
            }
        }
        .textSelection(.enabled)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditView = true
                    editingStock = stock
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
                    stock: $editingStock
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
                                isPresentingEditView = false
                                stock = editingStock
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
            document: ExportableEntityDocument(entity: stock),
            contentType: .json,
            defaultFilename: "\(stock.name)_Stock"
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error exporting file: \(error)")
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

    func saveChanges() {
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
        if editingStock.name.isEmpty {
            alertMessage = "Stock name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview {
    StockDetailView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: StockData.sampleData[0]
    )
    .environmentObject(EnvironmentManager.sampleData)
}
