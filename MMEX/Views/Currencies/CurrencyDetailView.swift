//
//  CurrencyDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyDetailView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @State var currency: CurrencyData

    @State private var editingCurrency = CurrencyData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(header: Text("Name")) {
                Text(currency.name)
            }
            Section(header: Text("Symbol")) {
                Text(currency.symbol)
            }

            if !currency.unitName.isEmpty {
                Section(header: Text("Unit Name")) {
                    Text(currency.unitName)
                }
                if !currency.centName.isEmpty {
                    Section(header: Text("Cent Name")) {
                        Text(currency.centName)
                    }
                }
            }

            Section(header: Text("Format")) {
                let amount: Double = 12345.67
                Text(amount.formatted(by: currency.formatter))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
/*
            Section(header: Text("Prefix Symbol")) {
                Text(currency.prefixSymbol)
            }
            Section(header: Text("Suffix Symbol")) {
                Text(currency.suffixSymbol)
            }
            Section(header: Text("Scale")) {
                Text("\(currency.scale)")
            }
*/

            Section(header: Text("Conversion Rate")) {
                Text("\(currency.baseConvRate)")
            }
            Section(header: Text("Type")) {
                Text(currency.type.rawValue)
            }
            // cannot delete currency in use
            if env.currencyCache[currency.id] == nil {
                Button("Delete Currency") {
                    deleteCurrency()
                }
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
                CurrencyEditView(
                    currency: $editingCurrency
                )
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
                            updateCurrency()
                        }
                    }
                }
            }
        }
    }

    func updateCurrency() {
        guard let repository = env.currencyRepository else { return }
        if repository.update(currency) {
            if env.currencyCache[currency.id] != nil {
                env.currencyCache.update(id: currency.id, data: currency)
            }
            // Handle success
        } else {
            // Handle failure
        }
    }

    func deleteCurrency() {
        guard env.currencyCache[currency.id] == nil else { return }
        guard let repository = env.currencyRepository else { return }
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
    .environmentObject(EnvironmentManager.sampleData)
}
