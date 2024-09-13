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
    @State private var currency: Currency?
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
                if let currency = currency {
                    Text(currency.name)
                } else {
                    Text("Loading currency...")
                }            }
            Section(header: Text("Balance")) {
                if let currency = currency {
                    Text(currency.format(amount: account.balance ?? 0.0))
                } else {
                    Text("\(account.balance ?? 0.0)")
                }
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
        .textSelection(.enabled)
        .onAppear() {
            loadCurrency()
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

    func loadCurrency() {
        currency = currencies.first { $0.id == account.currencyId }
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
}

#Preview {
    AccountDetailView(account: Account.sampleData[0], databaseURL: URL(string: "path/to/database")!, currencies: .constant(Currency.sampleData))
}
