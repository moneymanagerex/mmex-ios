//
//  ManageView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManageView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool
    
    var body: some View {
        List {
            Section(header: Text("Data")) {
                NavigationLink(destination: CurrencyListView()) {
                    Text("Currencies")
                }
                NavigationLink(destination: AccountListView()) {
                    Text("Accounts")
                }
                NavigationLink(destination: AssetListView()) {
                    Text("Assets")
                }
                NavigationLink(destination: StockListView()) {
                    Text("Stocks")
                }
                NavigationLink(destination: CategoryListView()) {
                    Text("Categories")
                }
                NavigationLink(destination: PayeeListView()) {
                    Text("Payees")
                }
                NavigationLink(destination: TransactionListView(viewModel: viewModel)) {
                    Text("Transactions")
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
                    env.closeDatabase() // Calls method to handle closing the database
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
    ManageView(
        viewModel: TransactionViewModel(env: EnvironmentManager()),
        isDocumentPickerPresented: .constant(false),
        isNewDocumentPickerPresented: .constant(false),
        isSampleDocument: .constant(false)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
