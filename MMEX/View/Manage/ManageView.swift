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
    @ObservedObject var vm: ViewModel
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool

    var body: some View {
        List {
            Section(header: Text("Data")) {
                NavigationLink(destination: CurrencyListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(CurrencyData.dataName.1) },
                        count: vm.currencyList.count
                    )
                }
                NavigationLink(destination: AccountListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(AccountData.dataName.1) },
                        count: vm.accountList.count
                    )
                }
                NavigationLink(destination: AssetListView()) {
                    env.theme.group.manageItem(
                        name: { Text(AssetData.dataName.1) },
                        count: vm.assetList.count
                    )
                }
                NavigationLink(destination: StockListView()) {
                    env.theme.group.manageItem(
                        name: { Text(StockData.dataName.1) },
                        count: vm.stockList.count
                    )
                }
                NavigationLink(destination: CategoryListView(viewModel: viewModel)) {
                    env.theme.group.manageItem(
                        name: { Text(CategoryData.dataName.1) },
                        count: vm.categoryList.count
                    )
                }
                NavigationLink(destination: PayeeListView()) {
                    env.theme.group.manageItem(
                        name: { Text(PayeeData.dataName.1) },
                        count: vm.payeeList.count
                    )
                }
                NavigationLink(destination: TransactionListView(viewModel: viewModel)) {
                    env.theme.group.manageItem(
                        name: { Text(TransactionData.dataName.1) },
                        count: vm.transactionCount
                    )
                }
            }
            
            Section(header: Text("Database")) {
                Button(action: {
                    isDocumentPickerPresented = true
                }) {
                    Text("Open Database")
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
        .task {
            await vm.loadManageList()
        }
    }
}

#Preview {
    ManageView(
        viewModel: TransactionViewModel(env: EnvironmentManager.sampleData),
        vm: ViewModel(env: EnvironmentManager.sampleData),
        isDocumentPickerPresented: .constant(false),
        isNewDocumentPickerPresented: .constant(false),
        isSampleDocument: .constant(false)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
