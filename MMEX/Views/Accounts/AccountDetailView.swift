//
//  AccountDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct AccountDetailView: View {
    @State var account: AccountData
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @Binding var currencyName: [(Int64, String)] // Bind to the list of available currencies

    @State private var editingAccount = AccountData()
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
                if let currency = dataManager.currencyCache[account.currencyId] {
                    Text(currency.name)
                } else {
                    Text("Unknown currency!")
                }
            }
            Section(header: Text("Initial Date")) {
                Text(account.initialDate)
            }
            Section(header: Text("Initial Balance")) {
                Text(account.initialBal.formatted(
                    by: dataManager.currencyCache[account.currencyId]?.formatter
                ))
            }
            Section(header: Text("Notes")) {
                Text(account.notes)  // Display notes if they are not nil
            }
            // TODO: cannot delete account in use
            Button("Delete Account") {
                deleteAccount()
            }
            .foregroundColor(.red)
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
                AccountEditView(
                    account: $editingAccount,
                    currencyName: $currencyName
                )
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
        guard let repository = dataManager.accountRepository else { return }
        if repository.update(account) {
            // Successfully updated
            if dataManager.currencyCache[account.currencyId] == nil {
                dataManager.loadCurrency()
            }
            dataManager.updateAccount(id: account.id, data: account)
        } else {
            // Handle failure
        }
    }
    
    func deleteAccount() {
        guard let repository = dataManager.accountRepository else { return }
        if repository.delete(account) {
            dataManager.loadAccount()
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    AccountDetailView(
        account: AccountData.sampleData[0],
        currencyName: .constant(CurrencyData.sampleData.map {
            ($0.id, $0.name)
        } )
    )
    .environmentObject(DataManager())
}

#Preview {
    AccountDetailView(
        account: AccountData.sampleData[1],
        currencyName: .constant(CurrencyData.sampleData.map {
            ($0.id, $0.name)
        } )
    )
    .environmentObject(DataManager())
}
