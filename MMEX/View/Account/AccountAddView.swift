//
//  AccountAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountAddView: View {
    @Binding var allCurrencyName: [(Int64, String)] // Bind to the list of available currencies
    @Binding var newAccount: AccountData
    @Binding var isPresentingAccountAddView: Bool

    var onSave: (inout AccountData) -> Void
    
    var body: some View {
        NavigationStack {
            AccountEditView(
                allCurrencyName: $allCurrencyName,
                account: $newAccount,
                edit: true
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
/*
#Preview {
    AccountAddView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        newAccount: .constant(AccountData()),
        isPresentingAccountAddView: .constant(true)
    ) { newAccount in
        // Handle saving in preview
        log.info("New account: \(newAccount.name)")
    }
}
*/
