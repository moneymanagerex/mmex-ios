//
//  AccountAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountAddView: View {
    @EnvironmentObject var env: EnvironmentManager
    @State var vm: RepositoryViewModel
    @Binding var isPresented: Bool

    @State private var data = AccountListView.newData
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            AccountEditView(
                vm: vm,
                data: $data,
                edit: true
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if validateAccount() {
                            addAccount(&data)
                            isPresented = false
                        } else {
                            isShowingAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Validation Error"),
                    message: Text(alertMessage), dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func validateAccount() -> Bool {
        if data.name.isEmpty {
            alertMessage = "Account name cannot be empty."
            return false
        }
        // TODO: Add more validation logic here if needed (e.g., category selection)
        return true
    }

    func addAccount(_ account: inout AccountData) {
        guard let repository = AccountRepository(env) else { return }
        if repository.insert(&account) {
            // self.accounts.append(account)
            if env.currencyCache[account.currencyId] == nil {
                // TODO: loadCurrency() -> addCurrency()
                env.loadCurrency()
            }
            env.accountCache.update(id: account.id, data: account)
            // TODO: update vm
        }
    }
}

/*
#Preview {
    AccountAddView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        newAccount: .constant(AccountData()),
        isPresentingAddView: .constant(true)
    ) { newAccount in
        // Handle saving in preview
        log.info("New account: \(newAccount.name)")
    }
}
*/
