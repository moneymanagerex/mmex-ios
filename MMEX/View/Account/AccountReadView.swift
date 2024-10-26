//
//  AccountReadView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountReadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @State var data: AccountData
    @Binding var newData: AccountData?
    @Binding var deleteData: Bool

    @State private var updateViewIsPresented = false
    @State private var exporterIsPresented = false

    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        Form {
            AccountEditForm(
                vm: vm,
                data: $data,
                edit: false
            )
            if vm.isUsed(data) == false {
                Button("Delete Account") {
                    let deleteError = vm.deleteAccount(data)
                    if deleteError != nil {
                        alertMessage = deleteError
                        alertIsPresented = true
                    } else {
                        deleteData = true
                        dismiss()
                    }
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
        .toolbar {
            Button("Edit") {
                updateViewIsPresented = true
            }
            // Export button for pasteboard and external storage
            Menu {
                Button("Copy to Clipboard") {
                    data.copyToPasteboard()
                }
                Button("Export as JSON File") {
                    exporterIsPresented = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .alert(isPresented: $alertIsPresented) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage!),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $updateViewIsPresented) {
            AccountUpdateView(
                vm: vm,
                title: data.name,
                data: data,
                newData: $newData,
                isPresented: $updateViewIsPresented,
                dismiss: dismiss
            )
        }
        .fileExporter(
            isPresented: $exporterIsPresented,
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
}

#Preview(AccountData.sampleData[0].name) {
    let env = EnvironmentManager.sampleData
    AccountReadView(
        vm: ViewModel(env: env),
        data: AccountData.sampleData[0],
        newData: .constant(nil),
        deleteData: .constant(false)
    )
    .environmentObject(env)
}

#Preview(AccountData.sampleData[1].name) {
    let env = EnvironmentManager.sampleData
    AccountReadView(
        vm: ViewModel(env: env),
        data: AccountData.sampleData[1],
        newData: .constant(nil),
        deleteData: .constant(false)
    )
    .environmentObject(env)
}

#Preview(AccountData.sampleData[2].name) {
    let env = EnvironmentManager.sampleData
    AccountReadView(
        vm: ViewModel(env: env),
        data: AccountData.sampleData[2],
        newData: .constant(nil),
        deleteData: .constant(false)
    )
    .environmentObject(env)
}
