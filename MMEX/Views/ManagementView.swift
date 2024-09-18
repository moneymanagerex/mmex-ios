//
//  ManagementView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManagementView: View {
    let databaseURL: URL
    @Binding var isDocumentPickerPresented: Bool
    
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
            Section(header: Text("Manage Info")) {
                NavigationLink(destination: InfoTableView(databaseURL: databaseURL)) {
                    Text("Per Database Info")
                }
            }
            Section(header: Text("Database")) {
                Button("Re-open Database") {
                    isDocumentPickerPresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .navigationTitle("Management")
    }
}

#Preview {
    ManagementView(databaseURL: URL(string: "path/to/database")!, isDocumentPickerPresented: .constant(false))
}

#Preview {
    ManagementView(databaseURL: URL(string: "path/to/database")!, isDocumentPickerPresented: .constant(true))
}
