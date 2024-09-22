//
//  CurrencyDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyDetailView: View {
    @State var currency: Currency
    let databaseURL: URL
    @State private var editingCurrency = Currency.empty
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(header: Text("Currency Name")) {
                Text(currency.name)
            }
            Section(header: Text("Prefix Symbol")) {
                Text(currency.prefixSymbol ?? "N/A")
            }
            Section(header: Text("Suffix Symbol")) {
                Text(currency.suffixSymbol ?? "N/A")
            }
            Section(header: Text("Scale")) {
                Text("\(currency.scale ?? 0)")
            }
            Section(header: Text("Conversion Rate")) {
                Text("\(currency.baseConversionRate ?? 0)")
            }
            Section(header: Text("Currency Type")) {
                Text(currency.type)
            }
            Button("Delete Currency") {
                deleteCurrency()
            }
        }
        .textSelection(.enabled)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditView = true
                    editingCurrency = currency
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                CurrencyEditView(currency: $editingCurrency)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                currency = editingCurrency
                                saveChanges()
                            }
                        }
                    }
            }
        }
    }

    func saveChanges() {
        let repository = DataManager(databaseURL: databaseURL).getCurrencyRepository()
        if repository.update(currency) {
            // Handle success
        } else {
            // Handle failure
        }
    }

    func deleteCurrency() {
        let repository = DataManager(databaseURL: databaseURL).getCurrencyRepository()
        if repository.delete(currency) {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    CurrencyDetailView(currency: Currency.sampleData[0], databaseURL: URL(string: "path/to/database")!)
}
