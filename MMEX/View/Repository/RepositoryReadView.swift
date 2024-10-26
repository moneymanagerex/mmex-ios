//
//  RepositoryReadView.swift
//  MMEX
//
//  2024-09-05: (AccountDetailView) Created by Lisheng Guan
//  2024-10-26: (RepositoryReadView) Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryReadView<
    MainData: DataProtocol,
    EditView: View
>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @State var data: MainData
    @Binding var newData: MainData?
    @Binding var deleteData: Bool
    @ViewBuilder var editView: (_ data: Binding<MainData>, _ edit: Bool) -> EditView

    @State private var updateViewIsPresented = false
    @State private var exporterIsPresented = false

    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        Form {
            editView($data, false)
            if vm.isUsed(data) == false {
                Button("Delete Account") {
                    let deleteError = vm.delete(data)
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
            RepositoryUpdateView(
                vm: vm,
                title: vm.name(data),
                data: data,
                newData: $newData,
                isPresented: $updateViewIsPresented,
                dismiss: dismiss,
                editView: editView
            )
        }
        .fileExporter(
            isPresented: $exporterIsPresented,
            document: ExportableEntityDocument(entity: data),
            contentType: .json,
            defaultFilename: vm.filename(data)
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
    let vm = ViewModel(env: env)
    RepositoryReadView(
        vm: vm,
        data: AccountData.sampleData[0],
        newData: .constant(nil),
        deleteData: .constant(false),
        editView: { $data, edit in AccountEditView(
            vm: vm,
            data: $data,
            edit: edit
        ) }
    )
    .environmentObject(env)
}
