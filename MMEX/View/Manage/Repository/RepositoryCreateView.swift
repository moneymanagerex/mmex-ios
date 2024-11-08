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
    EditView: View
>: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @State var data: MainData
    @Binding var newData: MainData?
    @Binding var isPresented: Bool
    @ViewBuilder var editView: (_ data: Binding<MainData>, _ edit: Bool) -> EditView

    @State private var alertIsPresented = false
    @State private var alertMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                editView($data, true)
            }
            .textSelection(.enabled)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let createError = vm.update(&data) {
                            alertMessage = createError
                            alertIsPresented = true
                        } else {
                            newData = data
                            isPresented = false
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

#Preview("Account") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    RepositoryCreateView(
        vm: vm,
        data: AccountListView.initData,
        newData: .constant(nil),
        isPresented: .constant(true),
        editView: { $data, edit in AccountEditView(
            vm: vm,
            data: $data,
            edit: edit
        ) }
    )
    .environmentObject(env)
}
