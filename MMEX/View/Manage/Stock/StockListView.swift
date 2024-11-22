//
//  StockListView.swift
//  MMEX
//
//  2024-10-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockListView: View {
    typealias MainData = StockData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = StockData(
    )

    @State var search: StockSearch = .init()

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: Self.features,
            vmList: vm.stockList,
            groupChoice: vm.stockGroup.choice,
            vmGroup: $vm.stockGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: StockListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    @ViewBuilder
    func itemNameView(_ data: StockData) -> some View {
        Text(data.name)
    }

    @ViewBuilder
    func itemInfoView(_ data: StockData) -> some View {
        if vm.stockGroup.choice == .account {
            Text(data.symbol)
        } else {
            Text(vm.accountList.data.readyValue?[data.accountId]?.name ?? "")
        }
        /*
         if
           let account = vm.accountList.data.readyValue?[data.accountId],
           let formatter = vm.currencyList.info.readyValue?[account.currencyId]?.formatter
         {
           Text(data.purchaseValue.formatted(by: formatter))
         }
         */
    }

    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        StockFormView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    NavigationView {
        StockListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
