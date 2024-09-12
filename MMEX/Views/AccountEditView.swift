//
//  AccountEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountEditView: View {
    @Binding var account: Account
    
    var body: some View {
        Form {
            Section(header: Text("Account Name")) {
                TextField("Account Name", text: $account.name)
            }
            Section(header: Text("Account Type")) {
                TextField("Account Type", text: $account.type)
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $account.status) {
                    ForEach(Status.allCases) { status in
                        Text(status.name).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Currency ID")) {
                TextField("Currency ID", value: $account.currencyId, format: .number)
            }
            Section(header: Text("Favorite Account")) {
                TextField("Favorite Account", text: $account.favoriteAcct)
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
    AccountEditView(account: .constant(Account.empty))
}
