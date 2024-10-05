//
//  AccountDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var env: EnvironmentManager
    @Binding var allCurrencyName: [(Int64, String)] // sorted by name
    @State var account: AccountData

    @State private var editingAccount = AccountData()
    @State private var isPresentingEditView = false
    
    @State private var isExporting = false

    var body: some View {
        let currency = env.currencyCache[account.currencyId]
        let formatter = currency?.formatter
        List {
            Section(header: Text("Name")) {
                Text(account.name)
            }
            Section(header: Text("Type")) {
                Text(account.type.name)
            }
            // TODO link to currency details
            Section(header: Text("Currency")) {
                Text(currency?.name ?? "Unknown currency!")
            }

            // TODO: convert to Bool, show as button
            Section(header: Text("Favorite")) {
                Text(account.favoriteAcct)
            }
            Section(header: Text("Status")) {
                Text(account.status.id)
            }
            Section(header: Text("Initial Date")) {
                Text(account.initialDate)
            }
            Section(header: Text("Initial Balance")) {
                Text(account.initialBal.formatted(by: formatter))
            }

            Section(header: Text("Statement Locked")) {
                Text(account.statementLocked ? "YES" : "NO")
            }
            Section(header: Text("Statement Date")) {
                Text(account.statementDate)
            }
            Section(header: Text("Minimum Balance")) {
                Text(account.minimumBalance.formatted(by: formatter))
            }
            Section(header: Text("Credit Limit")) {
                Text(account.creditLimit.formatted(by: formatter))
            }
            Section(header: Text("Interest Rate")) {
                Text("\(account.interestRate)")
            }
            Section(header: Text("Payment Due Date")) {
                Text(account.paymentDueDate)
            }
            Section(header: Text("Minimum Payment")) {
                Text(account.minimumPayment.formatted(by: formatter))
            }

            if !account.num.isEmpty {
                Section(header: Text("Number")) {
                    Text(account.num)
                }
            }
            if !account.heldAt.isEmpty {
                Section(header: Text("Held at")) {
                    Text(account.heldAt)
                }
            }
            if !account.website.isEmpty {
                Section(header: Text("Website")) {
                    Text(account.website)
                }
            }
            if !account.contactInfo.isEmpty {
                Section(header: Text("Contact Info")) {
                    Text(account.contactInfo)
                }
            }
            if !account.accessInfo.isEmpty {
                Section(header: Text("Access Info")) {
                    Text(account.accessInfo)
                }
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
                    allCurrencyName: $allCurrencyName,
                    account: $editingAccount
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
                            updateAccount()
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
                log.info("File saved to: \(url)")
            case .failure(let error):
                log.error("Error exporting file: \(error)")
            }
        }
    }

    func updateAccount() {
        guard let repository = env.accountRepository else { return }
        if repository.update(account) {
            // Successfully updated
            if env.currencyCache[account.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: account.id, data: account)
        } else {
            // Handle failure
        }
    }
    
    func deleteAccount() {
        guard let repository = env.accountRepository else { return }
        if repository.delete(account) {
            env.loadAccount()
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    AccountDetailView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: AccountData.sampleData[0]
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview {
    AccountDetailView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: AccountData.sampleData[1]
    )
    .environmentObject(EnvironmentManager.sampleData)
}
