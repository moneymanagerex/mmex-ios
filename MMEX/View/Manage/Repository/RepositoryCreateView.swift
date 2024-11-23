//
//  RepositoryCreateView.swift
//  MMEX
//
//  2024-09-09: (AccountAddView) Created by Lisheng Guan
//  2024-10-26: (RepositoryCreateView) Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryCreateView<
    MainData: DataProtocol,
    FormView: View
>: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    var features: RepositoryFeatures
    @State var data: MainData
    @Binding var newData: MainData?
    @Binding var isPresented: Bool
    var dismiss: DismissAction?
    @ViewBuilder var formView: (_ data: Binding<MainData>, _ edit: Bool) -> FormView

    @State private var alertIsPresented = false
    @State private var alertMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                formView($data, true)
            }
            .textSelection(.enabled)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Create")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let updateError = vm.update(&data) {
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
}

#Preview("Account") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    let formView = { $data, edit in AccountFormView(
        vm: vm,
        data: $data,
        edit: edit
    ) }
    RepositoryCreateView(
        vm: vm,
        features: RepositoryFeatures(),
        data: AccountListView.initData,
        newData: .constant(nil),
        isPresented: .constant(true),
        formView: formView
    )
    .environmentObject(pref)
    .environmentObject(env)
}
