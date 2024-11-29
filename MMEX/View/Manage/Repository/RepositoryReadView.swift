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
    FormView: View
>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: ViewModel
    let features: RepositoryFeatures
    @State var data: MainData
    let isUsed: Bool?
    @Binding var newData: MainData?
    @Binding var deleteData: Bool
    @ViewBuilder let formView: (_ focus: Binding<Bool>, _ data: Binding<MainData>, _ edit: Bool) -> FormView

    @State private var focus = false
    @State private var editSheetIsPresented = false
    @State private var copySheetIsPresented = false
    @State private var exporterIsPresented = false
    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        Form {
            formView($focus, $data, false)
            if isUsed == false {
                Button("Delete \(MainData.dataName.0)") {
                    if let deleteError = data.delete(vm) {
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
                        .font(.footnote)
                }
            }

            if features.canCopy {
                Button {
                    copySheetIsPresented = true
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.footnote)
                }
            }

            if features.canEdit {
                Button {
                    editSheetIsPresented = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.footnote)
                }
            }
        }

        .sheet(isPresented: $editSheetIsPresented) {
            NavigationView {
                RepositoryEditView(
                    isPresented: $editSheetIsPresented,
                    features: features,
                    data: data,
                    newData: $newData,
                    dismiss: dismiss,
                    formView: formView
                )
                .navigationBarTitle("Edit", displayMode: .inline)
            }
        }

        .sheet(isPresented: $copySheetIsPresented) {
            NavigationView {
                RepositoryCopyView(
                    isPresented: $copySheetIsPresented,
                    features: features,
                    data: data,
                    newData: $newData,
                    dismiss: dismiss,
                    formView: formView
                )
                .navigationBarTitle("Copy", displayMode: .inline)
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
    let data = AccountData.sampleData[0]
    let formView = { $focus, $data, edit in AccountFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
    MMEXPreview.manageList { pref, vm in
        RepositoryReadView(
            features: RepositoryFeatures(),
            data: data,
            isUsed: nil,
            newData: .constant(nil),
            deleteData: .constant(false),
            formView: formView
        )
        .navigationTitle(AccountData.dataName.1)
    }
}

extension MMEXPreview {
    @ViewBuilder
    static func manageRead<MainData: DataProtocol, FormView: View>(
        _ data: MainData,
        @ViewBuilder formView: @escaping (
            _ focus: Binding<Bool>, _ data: Binding<MainData>, _ edit: Bool
        ) -> FormView
    ) -> some View {
        MMEXPreview.manageList { pref, vm in
            RepositoryReadView(
                features: RepositoryFeatures(),
                data: data,
                isUsed: nil,
                newData: .constant(nil),
                deleteData: .constant(false),
                formView: formView
            )
            .navigationTitle(MainData.dataName.1)
        }
    }
}
