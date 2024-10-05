//
//  AccountEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountEditView: View {
    @Binding var allCurrencyName: [(Int64, String)] // sorted by name
    @Binding var account: AccountData

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
                    ForEach(allCurrencyName, id: \.0) { id, name in
                        Text(name).tag(id) // Use currency.name to display and tag by id
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
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: .constant(AccountData.sampleData[0])
    )
}

#Preview {
    AccountEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: .constant(AccountData.sampleData[1])
    )
}
