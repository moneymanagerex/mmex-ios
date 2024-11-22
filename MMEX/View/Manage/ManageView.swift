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

    let groupTheme = GroupTheme(layout: .nameFold)
    @State var auxDataIsExpanded = false
    var auxCount: [Int?] {[
        vm.currencyList.count.readyValue,
        vm.tagList.count.readyValue,
        vm.attachmentList.count.readyValue,
    ]}
    var auxSum: Int? {
        auxCount.reduce(0 as Int?, { sum, next in
            if let sum, let next { sum + next } else { nil }
        } )
    }

    var body: some View {
        List {
            groupTheme.section(
                nameView: { Text("Data") }
            ) {
                NavigationLink(destination: AccountListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(AccountData.dataName.1) },
                        count: vm.accountList.count
                    )
                }
                NavigationLink(destination: AssetListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(AssetData.dataName.1) },
                        count: vm.assetList.count
                    )
                }
                NavigationLink(destination: StockListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(StockData.dataName.1) },
                        count: vm.stockList.count
                    )
                }
                NavigationLink(destination: CategoryListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(CategoryData.dataName.1) },
                        count: vm.categoryList.count
                    )
                }
                NavigationLink(destination: PayeeListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(PayeeData.dataName.1) },
                        count: vm.payeeList.count
                    )
                }
                NavigationLink(destination: TransactionListView(vm: vm, viewModel: viewModel)) {
                    env.theme.group.manageItem(
                        nameView: { Text(TransactionData.dataName.1) },
                        count: vm.transactionList.count
                    )
                }
            }

            groupTheme.section(
                nameView: { Text("Auxiliary Data") },
                count: (env.theme.group.showCount.asBool ? auxSum : nil),
                isExpanded: $auxDataIsExpanded
            ) {
                NavigationLink(destination: CurrencyListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(CurrencyData.dataName.1) },
                        count: vm.currencyList.count
                    )
                }
                NavigationLink(destination: TagListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(TagData.dataName.1) },
                        count: vm.tagList.count
                    )
                }
                NavigationLink(destination: AttachmentListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(AttachmentData.dataName.1) },
                        count: vm.attachmentList.count
                    )
                }
                NavigationLink(destination: BudgetPeriodListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(BudgetPeriodData.dataName.1) },
                        count: vm.budgetPeriodList.count
                    )
                }
                NavigationLink(destination: BudgetListView(vm: vm)) {
                    env.theme.group.manageItem(
                        nameView: { Text(BudgetData.dataName.1) },
                        count: vm.budgetList.count
                    )
                }
                /*
                Text("More coming soon ...")
                    .foregroundColor(.accentColor)
                    .opacity(0.6)
                 */
            }

            groupTheme.section(
                nameView: { Text("Database") }
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

            groupTheme.section(
                nameView: { Text("Database Maintenance") }
            ) {
                Text("Coming soon ...")
                    .foregroundColor(.accentColor)
                    .opacity(0.6)
            }
        }
        .listStyle(InsetGroupedListStyle()) // Better styling for iOS
        .listSectionSpacing(5)
        .padding(.top, -20)
        //.border(.red)

        .task {
            await vm.loadManageList()
        }
        
        .refreshable {
            vm.unloadList()
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
    let vm = ViewModel(env: env)
    let viewModel = TransactionViewModel(env: env)
    NavigationView {
        ManageView(
            vm: vm,
            viewModel: viewModel,
            isDocumentPickerPresented: .constant(false),
            isNewDocumentPickerPresented: .constant(false),
            isSampleDocument: .constant(false)
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
