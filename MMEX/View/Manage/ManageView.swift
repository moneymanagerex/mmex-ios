//
//  ManageView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManageView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool

    @State var auxDataIsExpanded = false

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
                NavigationLink(destination: AssetListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(AssetData.dataName.1) },
                        count: vm.assetList.count
                    )
                }
                NavigationLink(destination: StockListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(StockData.dataName.1) },
                        count: vm.stockList.count
                    )
                }
                NavigationLink(destination: CategoryListView(vm: vm, viewModel: viewModel)) {
                    env.theme.group.manageItem(
                        name: { Text(CategoryData.dataName.1) },
                        count: vm.categoryList.count
                    )
                }
                NavigationLink(destination: PayeeListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(PayeeData.dataName.1) },
                        count: vm.payeeList.count
                    )
                }
                NavigationLink(destination: TransactionListView(vm: vm, viewModel: viewModel)) {
                    env.theme.group.manageItem(
                        name: { Text(TransactionData.dataName.1) },
                        count: vm.transactionList.count
                    )
                }
            }
            
            Section(header: HStack {
                Button(action: { auxDataIsExpanded.toggle() }) {
                    env.theme.group.view(
                        name: { Text("Auxiliary Data") },
                        isExpanded: auxDataIsExpanded
                    )
                }
            } ) { if auxDataIsExpanded {
                Text("Coming soon ...")
                    .foregroundColor(.accentColor)
                    .opacity(0.6)
            } }

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
                .listRowInsets(.init( top: 1, leading: 2, bottom: 1, trailing: 2))

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
                .listRowInsets(.init( top: 1, leading: 2, bottom: 1, trailing: 2))

                if false {
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
                    .listRowInsets(.init( top: 1, leading: 2, bottom: 1, trailing: 2))
                }

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
                .listRowInsets(.init( top: 1, leading: 2, bottom: 1, trailing: 2))
            }

            Section(header: Text("Database Maintenance")) {
                Text("Coming soon ...")
                    .foregroundColor(.accentColor)
                    .opacity(0.6)
            }

        }
        .listStyle(InsetGroupedListStyle()) // Better styling for iOS
        .task {
            await vm.loadManageList()
        }
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    ManageView(
        vm: ViewModel(env: env),
        viewModel: TransactionViewModel(env: env),
        isDocumentPickerPresented: .constant(false),
        isNewDocumentPickerPresented: .constant(false),
        isSampleDocument: .constant(false)
    )
    .environmentObject(env)
}
