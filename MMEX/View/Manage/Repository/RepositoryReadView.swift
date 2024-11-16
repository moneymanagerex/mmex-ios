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
    var features: RepositoryFeatures
    @State var data: MainData
    @Binding var newData: MainData?
    @Binding var deleteData: Bool
    @ViewBuilder var editView: (_ data: Binding<MainData>, _ edit: Bool) -> EditView

    @State private var copySheetIsPresented = false
    @State private var editSheetIsPresented = false
    @State private var exporterIsPresented = false
    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        Form {
            editView($data, false)
            if vm.isUsed(data) == false {
                Button("Delete \(MainData.dataName.0)") {
                    if let deleteError = vm.delete(data) {
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
            if features.canExport {
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

            if features.canCopy {
                Button {
                    copySheetIsPresented = true
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }

            if features.canEdit {
                Button {
                    editSheetIsPresented = true
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
            }
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

        .sheet(isPresented: $copySheetIsPresented) {
            RepositoryCopyView(
                vm: vm,
                features: features,
                data: data,
                newData: $newData,
                isPresented: $copySheetIsPresented,
                dismiss: dismiss,
                editView: editView
            )
        }

        .sheet(isPresented: $editSheetIsPresented) {
            RepositoryEditView(
                vm: vm,
                features: features,
                title: vm.name(data),
                data: data,
                newData: $newData,
                isPresented: $editSheetIsPresented,
                dismiss: dismiss,
                editView: editView
            )
        }

        .alert(isPresented: $alertIsPresented) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage!),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview(AccountData.sampleData[0].name) {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    let editView = { $data, edit in AccountEditView(
        vm: vm,
        data: $data,
        edit: edit
    ) }
    NavigationView {
        RepositoryReadView(
            vm: vm,
            features: RepositoryFeatures(),
            data: AccountData.sampleData[0],
            newData: .constant(nil),
            deleteData: .constant(false),
            editView: editView
        )
        .navigationTitle(AccountData.dataName.1)
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
