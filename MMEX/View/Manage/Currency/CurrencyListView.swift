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
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = CurrencyData(
        decimalPoint   : ".",
        groupSeparator : ",",
        scale          : 100,
        baseConvRate   : 1.0
    )

    @State var search: CurrencySearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.currencyList,
            groupChoice: vm.currencyGroup.choice,
            vmGroup: $vm.currencyGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: CurrencyListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    @ViewBuilder
    func itemNameView(_ data: CurrencyData) -> some View {
        Text(data.name)
    }
    
    @ViewBuilder
    func itemInfoView(_ data: CurrencyData) -> some View {
        Text(data.symbol)
    }

    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        CurrencyFormView(
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.sampleManage {
        CurrencyListView()
    }
}
