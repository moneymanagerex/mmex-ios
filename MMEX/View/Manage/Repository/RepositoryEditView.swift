//
//  RepositoryUpdateView.swift
//  MMEX
//
//  2024-09-05: (AccountDetailView) Created by Lisheng Guan on 2024/9/5.
//  2024-10-26: (RepositoryUpdateView) Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryEditView<
    MainData: DataProtocol,
    FormView: View
>: View {
    @EnvironmentObject var vm: ViewModel
    let features: RepositoryFeatures
    @State var data: MainData
    @Binding var newData: MainData?
    @Binding var isPresented: Bool
    var dismiss: DismissAction?
    @ViewBuilder var formView: (_ data: Binding<MainData>, _ edit: Bool) -> FormView

    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        Form {
            formView($data, true)
        }
        .textSelection(.enabled)
        .scrollDismissesKeyboard(.immediately)
        
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let updateError = data.update(vm) {
                        alertMessage = updateError
                        alertIsPresented = true
                    } else {
                        newData = data
                        isPresented = false
                        if let dismiss { dismiss() }
                    }
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
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
    MMEXPreview.sample {pref, vm in
        let data = AccountData.sampleData[0]
        let formView = { $data, edit in AccountFormView(
            data: $data,
            edit: edit
        ) }
        RepositoryEditView(
            features: RepositoryFeatures(),
            data: data,
            newData: .constant(nil),
            isPresented: .constant(true),
            dismiss: nil,
            formView: formView
        )
    }
}

extension MMEXPreview {
    @ViewBuilder
    static func repositoryEdit<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        MMEXPreview.sample { pref, vm in
            NavigationView {
                Form {
                    content()
                }
                .navigationBarTitle("Edit", displayMode: .inline)
            }
        }
    }
}
