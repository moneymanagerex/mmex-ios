//
//  AccountAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountAddView: View {
    @Binding var newAccount: AccountData
    @Binding var isPresentingAccountAddView: Bool
    @Binding var currencyName: [(Int64, String)] // Bind to the list of available currencies

    var onSave: (inout AccountData) -> Void
    
    var body: some View {
        NavigationStack {
            AccountEditView(
                account: $newAccount,
                currencyName: $currencyName
            )
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
        newAccount: .constant(AccountData()),
        isPresentingAccountAddView: .constant(true),
        currencyName: .constant(CurrencyData.sampleData.map {
            ($0.id, $0.name)
        } )
    ) { newAccount in
        // Handle saving in preview
        print("New account: \(newAccount.name)")
    }
}
