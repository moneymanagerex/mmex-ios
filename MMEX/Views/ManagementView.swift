//
//  ManagementView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManagementView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @ObservedObject var viewModel: InfotableViewModel
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool
    
    var body: some View {
        List {
            Section(header: Text("Manage Data")) {
                NavigationLink(destination: CurrencyListView()) {
                    Text("Manage Currencies")
                }
                NavigationLink(destination: AccountListView()) {
                    Text("Manage Accounts")
                }
                NavigationLink(destination: AssetListView()) {
                    Text("Manage Assets")
                }
                NavigationLink(destination: CategoryListView()) {
                    Text("Manage Categories")
                }
                NavigationLink(destination: PayeeListView()) {
                    Text("Manage Payees")
                }
                NavigationLink(destination: TransactionListView(viewModel: viewModel)) {
                    Text("Manage Transactions")
                }
            }
            
            Section(header: Text("Database")) {
                Button(action: {
                    isDocumentPickerPresented = true
                }) {
                    Text("Re-open Database")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button(action: {
                    isNewDocumentPickerPresented = true
                    isSampleDocument = false
                }) {
                    Text("New Database")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button(action: {
                    isNewDocumentPickerPresented = true
                    isSampleDocument = true
                }) {
                    Text("Sample Database")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Close Database Button
                Button(action: {
                    dataManager.closeDatabase() // Calls method to handle closing the database
                }) {
                    Text("Close Database")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .listStyle(InsetGroupedListStyle()) // Better styling for iOS
    }
}


#Preview {
    ManagementView(viewModel: InfotableViewModel(dataManager: DataManager()),
        isDocumentPickerPresented: .constant(false), isNewDocumentPickerPresented: .constant(false), isSampleDocument: .constant(false))
        .environmentObject(DataManager())
}
