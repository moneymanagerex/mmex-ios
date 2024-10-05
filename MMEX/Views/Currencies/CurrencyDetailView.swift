//
//  CurrencyDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var env: EnvironmentManager
    @Binding var currency: CurrencyData

    @State private var editCurrency = CurrencyData()
    @State private var isPresentingEditView = false

    var format: String {
        let amount: Double = 12345.67
        return amount.formatted(by: currency.formatter)
    }

    var body: some View {
        CurrencyEditView(
            currency: $currency,
            edit: false
        ) { () in
            deleteCurrency()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    editCurrency = currency
                    isPresentingEditView = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                CurrencyEditView(
                    currency: $editCurrency,
                    edit: true
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingEditView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            currency = editCurrency
                            updateCurrency()
                            isPresentingEditView = false
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
        currency: .constant(CurrencyData.sampleData[0])
    )
    .environmentObject(EnvironmentManager.sampleData)
}
