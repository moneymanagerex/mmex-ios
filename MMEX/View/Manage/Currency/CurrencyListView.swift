//
//  CurrencyListView.swift
//  MMEX
//
//  2024-09-17: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyListView: View {
    typealias MainData = CurrencyData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    let features = RepositoryFeatures()

    @State var search: CurrencySearch = .init()

    static let initData = CurrencyData(
        decimalPoint   : ".",
        groupSeparator : ",",
        scale          : 100,
        baseConvRate   : 1.0
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: features,
            vmList: vm.currencyList,
            groupChoice: vm.currencyGroup.choice,
            vmGroup: $vm.currencyGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: CurrencyListView.onAppear()")
        }
    }
    
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemNameView(_ data: CurrencyData) -> some View {
        Text(data.name)
    }
    
    func itemInfoView(_ data: CurrencyData) -> some View {
        Text(data.symbol)
    }

    func editView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        CurrencyEditView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    CurrencyListView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}