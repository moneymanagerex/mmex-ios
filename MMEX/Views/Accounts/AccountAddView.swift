//
//  AccountAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountAddView: View {
    @Binding var newAccount: AccountWithCurrency
    @Binding var isPresentingAccountAddView: Bool
    @Binding var currencies: [IdName] // Bind to the list of available currencies

    var onSave: (inout AccountWithCurrency) -> Void
    
    var body: some View {
        NavigationStack {
            AccountEditView(account: $newAccount, currencies: $currencies)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingAccountAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingAccountAddView = false
                            onSave(&newAccount)
                        }
                    }
                }
        }
    }
}

#Preview {
    AccountAddView(
        newAccount: .constant(AccountWithCurrency()),
        isPresentingAccountAddView: .constant(true),
        currencies: .constant(CurrencyData.sampleData.map {
            IdName(id: $0.id, name: $0.name)
        } )
    ) { newAccount in
        // Handle saving in preview
        print("New account: \(newAccount.data.name)")
    }
}
