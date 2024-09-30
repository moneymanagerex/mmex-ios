//
//  AccountEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountEditView: View {
    @Binding var account: AccountData
    @Binding var currencyName: [(Int64, String)] // Bind to the list of available currencies

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
                    ForEach(currencyName.indices, id: \.self) { i in
                        Text(currencyName[i].1).tag(currencyName[i].0) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }
            Section(header: Text("Favorite Account")) {
                Toggle(isOn: Binding(
                    get: { account.favoriteAcct == "TRUE" },
                    set: { account.favoriteAcct = $0 ? "TRUE" : "FALSE" }
                )) {
                    Text("Favorite Account")
                }
            }
            Section(header: Text("Initial Balance")) {
                TextField("Balance", value: $account.initialBal, format: .number)
            }
            Section(header: Text("Notes")) {
                TextField("Notes", text: Binding(
                    get: { account.notes },  // Provide a default value if nil
                    set: { account.notes = $0 }  // Set nil if empty
                ))
            }
        }
    }
}

#Preview {
    AccountEditView(
        account: .constant(AccountData.sampleData[0]),
        currencyName: .constant(CurrencyData.sampleData.map {
            ($0.id, $0.name)
        } )
    )
}

#Preview {
    AccountEditView(
        account: .constant(AccountData.sampleData[1]),
        currencyName: .constant(CurrencyData.sampleData.map {
            ($0.id, $0.name)
        } )
    )
}
