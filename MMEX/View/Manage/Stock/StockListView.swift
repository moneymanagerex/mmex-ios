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
    let features = RepositoryFeatures()

    @State var search: StockSearch = .init()

    static let initData = StockData(
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: features,
            vmList: vm.stockList,
            groupChoice: vm.stockGroup.choice,
            vmGroup: $vm.stockGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: StockListView.onAppear()")
        }
    }
    
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemNameView(_ data: StockData) -> some View {
        Text(data.name)
    }

    func itemInfoView(_ data: StockData) -> some View {
        Group {
            if vm.stockGroup.choice == .account {
                Text(data.symbol)
            } else {
                Text(vm.accountList.data.readyValue?[data.accountId]?.name ?? "")
            }
            /*
            if let account = vm.accountList.data.readyValue?[data.accountId],
               let formatter = vm.currencyList.info.readyValue?[account.currencyId]?.formatter
            {
                Text(data.purchaseValue.formatted(by: formatter))
            }
            */
        }
    }

    func editView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        StockEditView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    StockListView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}
