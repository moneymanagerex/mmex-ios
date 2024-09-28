//
//  AccountEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountEditView: View {
    @Binding var account: AccountWithCurrency
    @Binding var currencies: [IdName] // Bind to the list of available currencies

    var body: some View {
        Form {
            Section(header: Text("Account Name")) {
                TextField("Account Name", text: $account.data.name)
            }
            Section(header: Text("Account Type")) {
                Picker("Account Type", selection: $account.data.type) {
                    ForEach(AccountType.allCases) { type in
                        Text(type.name).tag(type)
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $account.data.status) {
                    ForEach(AccountStatus.allCases) { status in
                        Text(status.name).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Currency")) {
                Picker("Currency", selection: $account.data.currencyId) {
                    if (account.data.currencyId == 0) {
                        Text("Currency").tag(0 as Int64) // not set
                    }
                    ForEach(currencies) { currency in
                        Text(currency.name).tag(currency.id) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }
            Section(header: Text("Favorite Account")) {
                Toggle(isOn: Binding(
                    get: { account.data.favoriteAcct == "TRUE" },
                    set: { account.data.favoriteAcct = $0 ? "TRUE" : "FALSE" }
                )) {
                    Text("Favorite Account")
                }
            }
            Section(header: Text("Initial Balance")) {
                TextField("Balance", value: $account.data.initialBal, format: .number)
            }
            Section(header: Text("Notes")) {
                TextField("Notes", text: Binding(
                    get: { account.data.notes },  // Provide a default value if nil
                    set: { account.data.notes = $0 }  // Set nil if empty
                ))
            }
        }
    }
}

#Preview {
    AccountEditView(
        account: .constant(AccountData.sampleDataWithCurrency[0]),
        currencies: .constant(CurrencyData.sampleData.map {
            IdName(id: $0.id, name: $0.name)
        } )
    )
}

#Preview {
    AccountEditView(
        account: .constant(AccountData.sampleDataWithCurrency[1]),
        currencies: .constant(CurrencyData.sampleData.map {
            IdName(id: $0.id, name: $0.name)

        } )
    )
}
