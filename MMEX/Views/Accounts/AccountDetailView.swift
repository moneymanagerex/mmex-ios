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
    
    @State private var isExporting = false

    var body: some View {
        List {
            Section(header: Text("Account Name")) {
                Text(account.name)
            }
            Section(header: Text("Account Type")) {
                Text(account.type.name)
            }
            Section(header: Text("Status")) {
                Text(account.status.id)
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
                    Text(currency.format(amount: account.initialBal ?? 0.0))
                } else {
                    Text("\(account.initialBal ?? 0.0)")
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
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: account),
            contentType: .json,
            defaultFilename: "\(account.name)_Account"
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
        let repository = DataManager(databaseURL: databaseURL).getAccountRepository()
        if repository.update(account) {
            // Successfully updated
        } else {
            // Handle failure
        }
    }
    
    func deleteAccount() {
        let repository = DataManager(databaseURL: databaseURL).getAccountRepository()
        if repository.delete(account) {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    AccountDetailView(account: Account.sampleData[0], databaseURL: URL(string: "path/to/database")!, currencies: .constant(Currency.sampleData))
}

#Preview {
    AccountDetailView(account: Account.sampleData[1], databaseURL: URL(string: "path/to/database")!, currencies: .constant(Currency.sampleData))
}
