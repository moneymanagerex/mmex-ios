//
//  RepositoryUpdateView.swift
//  MMEX
//
//  2024-09-05: (AccountDetailView) Created by Lisheng Guan on 2024/9/5.
//  2024-10-26: (RepositoryUpdateView) Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryUpdateView<
    MainData: DataProtocol,
    EditView: View
>: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    var title: String
    @State var data: MainData
    @Binding var newData: MainData?
    @Binding var isPresented: Bool
    var dismiss: DismissAction?
    @ViewBuilder var editView: (_ data: Binding<MainData>, _ edit: Bool) -> EditView

    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                editView($data, true)
            }
            .textSelection(.enabled)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let updateError = vm.update(&data)
                        if updateError != nil {
                            alertMessage = updateError
                            alertIsPresented = true
                        } else {
                            newData = data
                            isPresented = false
                            if let dismiss { dismiss() }
                        }
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

#Preview(AccountData.sampleData[0].name) {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    let data = AccountData.sampleData[0]
    RepositoryUpdateView(
        vm: vm,
        title: vm.name(data),
        data: data,
        newData: .constant(nil),
        isPresented: .constant(true),
        dismiss: nil,
        editView: { $data, edit in AccountEditView(
            vm: vm,
            data: $data,
            edit: edit
        ) }
    )
    .environmentObject(env)
}