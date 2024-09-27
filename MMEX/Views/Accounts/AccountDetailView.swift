//
//  AccountDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct AccountDetailView: View {
    @State var account: AccountWithCurrency
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @Binding var currencies: [CurrencyData] // Bind to the list of available currencies

    @State private var editingAccount = AccountWithCurrency()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isExporting = false

    var body: some View {
        List {
            Section(header: Text("Account Name")) {
                Text(account.data.name)
            }
            Section(header: Text("Account Type")) {
                Text(account.data.type.name)
            }
            Section(header: Text("Status")) {
                Text(account.data.status.id)
            }
            // TODO link to currency details
            Section(header: Text("Currency")) {
                if let currency = account.currency {
                    Text(currency.name)
                } else {
                    Text("Loading currency...")
                }            }
            Section(header: Text("Balance")) {
                if let currency = account.currency {
                    Text(currency.format(amount: account.data.initialBal))
                } else {
                    Text("\(account.data.initialBal)")
                }
            }
            Section(header: Text("Notes")) {
                Text(account.data.notes)  // Display notes if they are not nil
            }
            Button("Delete Account") {
                deleteAccount()
            }
        }
        .textSelection(.enabled)
        .onAppear() {
            // TODO
        }
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingAccount = account
            }
            // Export button for pasteboard and external storage
            Menu {
                Button("Copy to Clipboard") {
                    account.copyToPasteboard()
                }
                Button("Export as JSON File") {
                    isExporting = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                AccountEditView(account: $editingAccount, currencies: $currencies)
                    .navigationTitle(account.data.name)
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
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: account),
            contentType: .json,
            defaultFilename: "\(account.data.name)_Account"
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error exporting file: \(error)")
            }
        }
    }

    func saveChanges() {
        let repository = dataManager.accountRepository
        if repository.update(account.data) {
            // Successfully updated
        } else {
            // Handle failure
        }
    }
    
    func deleteAccount() {
        let repository = dataManager.accountRepository
        if repository.delete(account.data) {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    AccountDetailView(
        account: AccountData.sampleDataWithCurrency[0],
        currencies: .constant(CurrencyData.sampleData))
}

#Preview {
    AccountDetailView(
        account: AccountData.sampleDataWithCurrency[1],
        currencies: .constant(CurrencyData.sampleData)
    )
}
