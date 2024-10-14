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
                    Text(CurrencyData.dataName.1)
                }
                NavigationLink(destination: AccountListView(
                    vm: AccountViewModel(env: env)
                )) {
                    Text(AccountData.dataName.1)
                }
                NavigationLink(destination: AssetListView()) {
                    Text(AssetData.dataName.1)
                }
                NavigationLink(destination: StockListView()) {
                    Text(StockData.dataName.1)
                }
                NavigationLink(destination: CategoryListView()) {
                    Text(CategoryData.dataName.1)
                }
                NavigationLink(destination: PayeeListView()) {
                    Text(PayeeData.dataName.1)
                }
                NavigationLink(destination: TransactionListView(viewModel: viewModel)) {
                    Text(TransactionData.dataName.1)
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
        viewModel: TransactionViewModel(env: EnvironmentManager.sampleData),
        isDocumentPickerPresented: .constant(false),
        isNewDocumentPickerPresented: .constant(false),
        isSampleDocument: .constant(false)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
