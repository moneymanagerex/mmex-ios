//
//  SettingsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct SettingsView: View {
    let databaseURL: URL
    
    var body: some View {
        List {
            Section(header: Text("Manage Data")) {
                NavigationLink(destination: AccountListView(databaseURL: databaseURL)) {
                    Text("Manage Accounts")
                }
                NavigationLink(destination: PayeeListView(databaseURL: databaseURL)) {
                    Text("Manage Payees")
                }
                NavigationLink(destination: CategoryListView(databaseURL: databaseURL)) {
                    Text("Manage Categories")
                }
                NavigationLink(destination: TransactionListView(databaseURL: databaseURL)) {
                    Text("Manage Transactions")
                }
                NavigationLink(destination: CurrencyListView(databaseURL: databaseURL)) {
                    Text("Manage Currencies")
                }
            }
        }
    }
}
