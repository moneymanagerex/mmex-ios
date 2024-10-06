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

    @State private var editAccount = AccountData()
    @State private var isPresentingEditView = false
    @State private var isExporting = false

    var body: some View {
        AccountEditView(
            allCurrencyName: $allCurrencyName,
            account: $account,
            edit: false
        ) { () in
            deleteAccount()
        }
        .toolbar {
            Button("Edit") {
                editAccount = account
                isPresentingEditView = true
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
                    account: $editAccount,
                    edit: true
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
                            account = editAccount
                            updateAccount()
                            isPresentingEditView = false
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

#Preview(AccountData.sampleData[0].name) {
    AccountDetailView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: AccountData.sampleData[0]
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview(AccountData.sampleData[1].name) {
    AccountDetailView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: AccountData.sampleData[1]
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview(AccountData.sampleData[2].name) {
    AccountDetailView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: AccountData.sampleData[2]
    )
    .environmentObject(EnvironmentManager.sampleData)
}
