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
    @State var viewModel: AccountViewModel
    @State var data: AccountData

    @State private var editAccount = AccountData()
    @State private var isPresentingEditView = false
    @State private var isExporting = false

    var body: some View {
        AccountEditView(
            viewModel: viewModel,
            data: $data,
            edit: false
        ) { () in
            deleteAccount()
        }
        .toolbar {
            Button("Edit") {
                editAccount = data
                isPresentingEditView = true
            }
            // Export button for pasteboard and external storage
            Menu {
                Button("Copy to Clipboard") {
                    data.copyToPasteboard()
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
                    viewModel: viewModel,
                    data: $data,
                    edit: true
                )
                .navigationTitle(data.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingEditView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            data = editAccount
                            updateAccount()
                            isPresentingEditView = false
                        }
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: data),
            contentType: .json,
            defaultFilename: "\(data.name)_Account"
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
        if repository.update(data) {
            // Successfully updated
            if env.currencyCache[data.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: data.id, data: data)
        } else {
            // Handle failure
        }
    }
    
    func deleteAccount() {
        guard let repository = env.accountRepository else { return }
        if repository.delete(data) {
            env.loadAccount()
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview(AccountData.sampleData[0].name) {
    AccountDetailView(
        viewModel: AccountViewModel(env: EnvironmentManager.sampleData),
        data: AccountData.sampleData[0]
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview(AccountData.sampleData[1].name) {
    AccountDetailView(
        viewModel: AccountViewModel(env: EnvironmentManager.sampleData),
        data: AccountData.sampleData[1]
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview(AccountData.sampleData[2].name) {
    AccountDetailView(
        viewModel: AccountViewModel(env: EnvironmentManager.sampleData),
        data: AccountData.sampleData[2]
    )
    .environmentObject(EnvironmentManager.sampleData)
}
