//
//  ManageView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManageView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool

    let groupTheme = GroupTheme(layout: .nameFold)
    @State var auxDataIsExpanded = false
    var auxCount: [Int?] {[
        vm.currencyList.count.readyValue,
        vm.tagList.count.readyValue,
        vm.fieldList.count.readyValue,
        vm.attachmentList.count.readyValue,
        vm.budgetPeriodList.count.readyValue,
        vm.budgetList.count.readyValue,
        vm.reportList.count.readyValue,
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
                NavigationLink(
                    destination: AccountListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(AccountData.dataName.1) },
                    count: vm.accountList.count
                ) }
                NavigationLink(
                    destination: AssetListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(AssetData.dataName.1) },
                    count: vm.assetList.count
                ) }
                NavigationLink(
                    destination: StockListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(StockData.dataName.1) },
                    count: vm.stockList.count
                ) }
                NavigationLink(
                    destination: CategoryListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(CategoryData.dataName.1) },
                    count: vm.categoryList.count
                ) }
                NavigationLink(
                    destination: PayeeListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(PayeeData.dataName.1) },
                    count: vm.payeeList.count
                ) }
                NavigationLink(
                    destination: TransactionListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(TransactionData.dataName.1) },
                    count: vm.transactionList.count
                ) }
            }

            groupTheme.section(
                nameView: { Text("Auxiliary Data") },
                count: (pref.theme.group.showCount.asBool && !auxDataIsExpanded ? auxSum : nil),
                isExpanded: $auxDataIsExpanded
            ) {
                NavigationLink(
                    destination: CurrencyListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(CurrencyData.dataName.1) },
                    count: vm.currencyList.count
                ) }
                NavigationLink(
                    destination: TagListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(TagData.dataName.1) },
                    count: vm.tagList.count
                ) }
                NavigationLink(
                    destination: FieldListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(FieldData.dataName.1) },
                    count: vm.fieldList.count
                ) }
                NavigationLink(
                    destination: AttachmentListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(AttachmentData.dataName.1) },
                    count: vm.attachmentList.count
                ) }
                NavigationLink(
                    destination: BudgetPeriodListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(BudgetPeriodData.dataName.1) },
                    count: vm.budgetPeriodList.count
                ) }
                NavigationLink(
                    destination: BudgetListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(BudgetData.dataName.1) },
                    count: vm.budgetList.count
                ) }
                NavigationLink(
                    destination: ReportListView()
                ) { pref.theme.group.manageItem(
                    nameView: { Text(ReportData.dataName.1) },
                    count: vm.reportList.count
                ) }
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
                    vm.closeDatabase()
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
            await vm.loadManageList(pref)
        }
        
        .refreshable {
            vm.unloadAllList()
            await vm.loadManageList(pref)
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
    MMEXPreview.sample { pref, vm in NavigationView {
        ManageView(
            isDocumentPickerPresented: .constant(false),
            isNewDocumentPickerPresented: .constant(false),
            isSampleDocument: .constant(false)
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    } }
}

extension MMEXPreview {
    @ViewBuilder
    static func sampleManage<Content: View>(
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        MMEXPreview.sample { pref, vm in NavigationView {
            content(pref, vm)
                .navigationBarTitle("Manage", displayMode: .inline)
        } }
    }
}
