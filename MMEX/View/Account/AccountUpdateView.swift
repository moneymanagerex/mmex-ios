//
//  AccountUpdateView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//  Edited 2024-10-23 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountUpdateView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    var title: String
    @State var data: AccountData
    @Binding var newData: AccountData?
    @Binding var isPresented: Bool
    var dismiss: DismissAction

    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                AccountEditForm(
                    vm: vm,
                    data: $data,
                    edit: true
                )
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
                        let updateError = vm.updateAccount(&data)
                        if updateError != nil {
                            alertMessage = updateError
                            alertIsPresented = true
                        } else {
                            newData = data
                            isPresented = false
                            dismiss()
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
