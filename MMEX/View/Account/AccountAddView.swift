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
    @Binding var isPresentingAddView: Bool
    var onSave: (inout AccountData) -> Void

    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
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
                        isPresentingAddView = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if validateAccount() {
                            onSave(&newAccount)
                            isPresentingAddView = false
                        } else {
                            isShowingAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Validation Error"),
                    message: Text(alertMessage), dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func validateAccount() -> Bool {
        if newAccount.name.isEmpty {
            alertMessage = "Account name cannot be empty."
            return false
        }

        // TODO: Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

/*
#Preview {
    AccountAddView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        newAccount: .constant(AccountData()),
        isPresentingAddView: .constant(true)
    ) { newAccount in
        // Handle saving in preview
        log.info("New account: \(newAccount.name)")
    }
}
*/
