//
//  AssetListView.swift
//  MMEX
//
//  2024-09-25: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetListView: View {
    typealias MainData = AssetData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = AssetData(
        status       : .open
    )

    @State var search: AssetSearch = .init()

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: Self.features,
            vmList: vm.assetList,
            groupChoice: vm.assetGroup.choice,
            vmGroup: $vm.assetGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: AssetListView.onAppear()")
        }
    }
    
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemNameView(_ data: AssetData) -> some View {
        Text(data.name)
    }

    func itemInfoView(_ data: AssetData) -> some View {
        Group {
            if vm.assetGroup.choice == .type {
                if let currencyName = vm.currencyList.name.readyValue {
                    Text(currencyName[data.currencyId] ?? "")
                }
            } else {
                Text(data.type.rawValue)
            }
            /*
            if let formatter = vm.currencyList.info.readyValue?[asset.currencyId]?.formatter
            {
                Text(asset.value.formatted(by: formatter))
            }
            */
        }
    }

    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        AssetFormView(
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
        AssetListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
