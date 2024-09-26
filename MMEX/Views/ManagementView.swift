//
//  ManagementView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManagementView: View {
    @Binding var isDocumentPickerPresented: Bool
    
    var body: some View {
        List {
            Section(header: Text("Manage Data")) {
                NavigationLink(destination: AccountListView()) {
                    Text("Manage Accounts")
                }
                NavigationLink(destination: AssetListView()) {
                    Text("Manage Assets")
                }
                NavigationLink(destination: PayeeListView()) {
                    Text("Manage Payees")
                }
                NavigationLink(destination: CategoryListView()) {
                    Text("Manage Categories")
                }
                NavigationLink(destination: TransactionListView()) {
                    Text("Manage Transactions")
                }
                NavigationLink(destination: CurrencyListView()) {
                    Text("Manage Currencies")
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
    }
}


#Preview {
    ManagementView(isDocumentPickerPresented: .constant(false))
}
