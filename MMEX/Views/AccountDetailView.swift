//
//  AccountDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct AccountDetailView: View {
    @State var account: Account
    let databaseURL: URL
    @Binding var currencies: [Currency] // Bind to the list of available currencies

    @State private var editingAccount = Account.empty
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            Section(header: Text("Account Name")) {
                Text(account.name)
            }
            Section(header: Text("Account Type")) {
                Text(account.type)
            }
            Section(header: Text("Status")) {
                Text(account.status.id)
            }
            // TODO link to currency details
            Section(header: Text("Currency")) {
                Text(getCurrencyName(for: account.currencyId))
            }
            Section(header: Text("Balance")) {
                Text("\(account.balance ?? 0.0)")
            }
            Section(header: Text("Notes")) {
                if let notes = account.notes {
                    Text(notes)  // Display notes if they are not nil
                } else {
                    Text("No notes available")  // Fallback text if notes are nil
                }
            }
            Button("Delete Account") {
                deleteAccount()
            }
        }
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingAccount = account
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                AccountEditView(account: $editingAccount, currencies: $currencies)
                    .navigationTitle(account.name)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                account = editingAccount
                                saveChanges()
                            }
                        }
                    }
            }
        }
        .navigationTitle("Account Details")
    }
    
    func saveChanges() {
        let repository = DataManager(databaseURL: databaseURL).getAccountRepository()
        if repository.updateAccount(account: account) {
            // Successfully updated
        } else {
            // Handle failure
        }
    }
    
    func deleteAccount() {
        let repository = DataManager(databaseURL: databaseURL).getAccountRepository()
        if repository.deleteAccount(account: account) {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }

    // TODO pre-join via SQL?
    func getCurrencyName(for currencyID: Int64) -> String {
        // Find the currency with the given ID
        return currencies.first { $0.id == currencyID }?.name ?? "Unknown"
    }
}

#Preview {
    AccountDetailView(account: Account.sampleData[0], databaseURL: URL(string: "path/to/database")!, currencies: .constant(Currency.sampleData))
}
