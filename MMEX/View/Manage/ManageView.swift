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
    let group = GroupTheme(layout: .nameFold)
    var auxCount: [Int?] {[
        vm.currencyList.count.readyValue,
        vm.tagList.count.readyValue,
    ]}
    var auxSum: Int? {
        auxCount.reduce(0 as Int?, { sum, next in
            if let sum, let next { sum + next } else { nil }
        } )
    }

    var body: some View {
        List {
            group.section(
                name: { Text("Data") }
            ) {
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

            group.section(
                name: { Text("Auxiliary Data") },
                count: auxSum,
                isExpanded: $auxDataIsExpanded
            ) {
                NavigationLink(destination: CurrencyListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(CurrencyData.dataName.1) },
                        count: vm.currencyList.count
                    )
                }
                NavigationLink(destination: TagListView(vm: vm)) {
                    env.theme.group.manageItem(
                        name: { Text(TagData.dataName.1) },
                        count: vm.tagList.count
                    )
                }
                Text("More coming soon ...")
                    .foregroundColor(.accentColor)
                    .opacity(0.6)
            }

            group.section(
                name: { Text("Database") }
            ) {
                databaseButton("Open Database", fg: .white, bg: .blue) {
                    isDocumentPickerPresented = true
                }
                databaseButton("New Database", fg: .white, bg: .green) {
                    isNewDocumentPickerPresented = true
                    isSampleDocument = false
                }
                
                if false {
                    databaseButton("Sample Database", fg: .white, bg: .orange) {
                        isNewDocumentPickerPresented = true
                        isSampleDocument = true
                    }
                }
                databaseButton("Close Database", fg: .white, bg: .red) {
                    env.closeDatabase()
                }
            }

            group.section(
                name: { Text("Database Maintenance") }
            ) {
                Text("Coming soon ...")
                    .foregroundColor(.accentColor)
                    .opacity(0.6)
            }
        }
        .listStyle(InsetGroupedListStyle()) // Better styling for iOS
        .listSectionSpacing(5)
        .task {
            await vm.loadManageList()
        }
    }
    
    func databaseButton(
        _ label: String, fg: Color, bg: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(bg)
        .foregroundColor(fg)
        .cornerRadius(10)
        .listRowInsets(.init( top: 1, leading: 2, bottom: 1, trailing: 2))
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
