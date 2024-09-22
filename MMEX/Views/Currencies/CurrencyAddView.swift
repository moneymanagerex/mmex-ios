//
//  CurrencyAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyAddView: View {
    @Binding var newCurrency: Currency
    @Binding var isPresentingCurrencyAddView: Bool

    var onSave: (inout Currency) -> Void

    var body: some View {
        NavigationStack {
            CurrencyEditView(currency: $newCurrency)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingCurrencyAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingCurrencyAddView = false
                            onSave(&newCurrency)
                        }
                    }
                }
        }
    }
}

#Preview {
    CurrencyAddView(
        newCurrency: .constant(Currency()),
        isPresentingCurrencyAddView: .constant(true)
    ) { newCurrency in
        // Handle saving in preview
        print("New currency: \(newCurrency.name)")
    }
}
