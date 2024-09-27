//
//  CurrencyDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyDetailView: View {
    @State var currency: CurrencyData
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State private var editingCurrency = CurrencyData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(header: Text("Currency Name")) {
                Text(currency.name)
            }
            Section(header: Text("Prefix Symbol")) {
                Text(currency.prefixSymbol)
            }
            Section(header: Text("Suffix Symbol")) {
                Text(currency.suffixSymbol)
            }
            Section(header: Text("Scale")) {
                Text("\(currency.scale)")
            }
            Section(header: Text("Conversion Rate")) {
                Text("\(currency.baseConvRate)")
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
        let repository = dataManager.currencyRepository
        if repository.update(currency) {
            // Handle success
        } else {
            // Handle failure
        }
    }

    func deleteCurrency() {
        let repository = dataManager.currencyRepository
        if repository.delete(currency) {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    CurrencyDetailView(
        currency: CurrencyData.sampleData[0]
    )
}
