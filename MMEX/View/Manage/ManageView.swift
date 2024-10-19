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
    @ObservedObject var expViewModel: ExpRepositoryViewModel
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool

    var body: some View {
        List {
            Section(header: Text("Data")) {
                NavigationLink(destination: CurrencyListView()) {
                    env.theme.group.manageItem(
                        name: { Text(CurrencyData.dataName.1) },
                        count: expViewModel.currencyCount.state
                    )
                }
                NavigationLink(destination: AccountListView(
                    vm: AccountViewModel().preloaded(env: env, group: AccountGroup.defaultValue)
                ) ) {
                    env.theme.group.manageItem(
                        name: { Text(AccountData.dataName.1) },
                        count: expViewModel.accountCount.state
                    )
                }
                NavigationLink(destination: AssetListView()) {
                    env.theme.group.manageItem(
                        name: { Text(AssetData.dataName.1) },
                        count: expViewModel.assetCount.state
                    )
                }
                NavigationLink(destination: StockListView()) {
                    env.theme.group.manageItem(
                        name: { Text(StockData.dataName.1) },
                        count: expViewModel.stockCount.state
                    )
                }
                NavigationLink(destination: CategoryListView()) {
                    env.theme.group.manageItem(
                        name: { Text(CategoryData.dataName.1) },
                        count: expViewModel.categoryCount.state
                    )
                }
                NavigationLink(destination: PayeeListView()) {
                    env.theme.group.manageItem(
                        name: { Text(PayeeData.dataName.1) },
                        count: expViewModel.payeeCount.state
                    )
                }
                NavigationLink(destination: TransactionListView(viewModel: viewModel)) {
                    env.theme.group.manageItem(
                        name: { Text(TransactionData.dataName.1) },
                        count: expViewModel.transactionCount.state
                    )
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
        .task {
            await expViewModel.loadManage(env: env)
        }
    }
}

#Preview {
    ManageView(
        viewModel: TransactionViewModel(env: EnvironmentManager.sampleData),
        expViewModel: ExpRepositoryViewModel(),
        isDocumentPickerPresented: .constant(false),
        isNewDocumentPickerPresented: .constant(false),
        isSampleDocument: .constant(false)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
