//
//  RepositoryCopyView.swift
//  MMEX
//
//  2024-11-16: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryCopyView<
    MainData: DataProtocol,
    FormView: View
>: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
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
            .navigationTitle("Copy")
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
        .onAppear {
            vm.copy(&data)
        }
    }
}

#Preview(AccountData.sampleData[0].name) {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    let data = AccountData.sampleData[0]
    let formView = { $data, edit in AccountFormView(
        vm: vm,
        data: $data,
        edit: edit
    ) }
    RepositoryCopyView(
        vm: vm,
        features: RepositoryFeatures(),
        data: data,
        newData: .constant(nil),
        isPresented: .constant(true),
        dismiss: nil,
        formView: formView
    )
    .environmentObject(pref)
    .environmentObject(env)
}
