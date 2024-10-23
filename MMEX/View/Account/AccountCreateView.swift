//
//  AccountCreateView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountCreateView: View {
    @EnvironmentObject var env: EnvironmentManager
    @State var vm: RepositoryViewModel
    @State var data: AccountData
    @Binding var newData: AccountData?
    @Binding var isPresented: Bool

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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let createError = vm.createAccount(&data) {
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

/*
#Preview {
    AccountCreateView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        newAccount: .constant(AccountData()),
        isPresentingAddView: .constant(true)
    ) { newAccount in
        // Handle saving in preview
        log.info("New account: \(newAccount.name)")
    }
}
*/
