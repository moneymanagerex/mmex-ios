//
//  AccountEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountEditView: View {
    @Binding var account: Account
    @Binding var currencies: [Currency] // Bind to the list of available currencies

    var body: some View {
        Form {
            Section(header: Text("Account Name")) {
                TextField("Account Name", text: $account.name)
            }
            Section(header: Text("Account Type")) {
                Picker("Account Type", selection: $account.type) {
                    ForEach(AccountType.allCases) { type in
                        Text(type.name).tag(type)
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $account.status) {
                    ForEach(AccountStatus.allCases) { status in
                        Text(status.name).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Currency")) {
                Picker("Currency", selection: $account.currencyId) {
                    if (account.currencyId == 0) {
                        Text("Currency").tag(0 as Int64) // not set
                    }
                    ForEach(currencies) { currency in
                        Text(currency.name).tag(currency.id) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }
            Section(header: Text("Favorite Account")) {
                Toggle(isOn: Binding(get: {
                    account.favoriteAcct == "TRUE"
                }, set: { newValue in
                    account.favoriteAcct = newValue ? "TRUE" : "FALSE"
                })) {
                    Text("Favorite Account")
                }
            }
            Section(header: Text("Balance")) {
                TextField("Balance", value: $account.balance, format: .number)
            }
            Section(header: Text("Notes")) {
                TextField("Notes", text: Binding(
                    get: { account.notes ?? "" },  // Provide a default value if nil
                    set: { account.notes = $0.isEmpty ? nil : $0 }  // Set nil if empty
                ))
            }
        }
    }
}

#Preview {
    AccountEditView(account: .constant(Account.sampleData[0]), currencies: .constant(Currency.sampleData))
}

#Preview {
    AccountEditView(account: .constant(Account.sampleData[1]), currencies: .constant(Currency.sampleData))
}
