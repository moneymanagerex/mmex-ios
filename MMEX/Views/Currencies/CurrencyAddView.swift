//
//  CurrencyAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyAddView: View {
    @Binding var newCurrency: CurrencyData
    @Binding var isPresentingAddView: Bool

    var onSave: (inout CurrencyData) -> Void

    var body: some View {
        NavigationStack {
            CurrencyEditView(
                currency: $newCurrency,
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
                        isPresentingAddView = false
                        onSave(&newCurrency)
                    }
                }
            }
        }
    }
}
/*
#Preview {
    CurrencyAddView(
        newCurrency: .constant(CurrencyData()),
        isPresentingAddView: .constant(true)
    ) { newCurrency in
        // Handle saving in preview
        log.info("New currency: \(newCurrency.name)")
    }
}
*/
