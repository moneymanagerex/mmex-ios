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
    @Binding var isPresented: Bool
    let features: RepositoryFeatures
    @State var data: MainData
    @Binding var newData: MainData?
    var dismiss: DismissAction?
    @ViewBuilder var formView: (_ focus: Binding<Bool>, _ data: Binding<MainData>, _ edit: Bool) -> FormView

    @State private var focus = false
    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        Form {
            formView($focus, $data, true)
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
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
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
        let formView = { $isFocused, $data, edit in AccountFormView(
            focus: $isFocused,
            data: $data,
            edit: edit
        ) }
        RepositoryEditView(
            isPresented: .constant(true),
            features: RepositoryFeatures(),
            data: data,
            newData: .constant(nil),
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
