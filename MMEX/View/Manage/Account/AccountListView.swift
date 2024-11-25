//
//  AccountListView.swift
//  MMEX
//
//  2024-09-05: Created by Lisheng Guan
//  2024-10-11: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountListView: View {
    typealias MainData = AccountData
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    @State var search: AccountSearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.accountList,
            groupChoice: vm.accountGroup.choice,
            vmGroup: $vm.accountGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: AccountListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        switch vm.accountGroup.choice {
        case .type:
            HStack {
                Image(systemName: AccountGroup.groupType[g].symbolName)
                    .frame(minWidth: 10, alignment: .leading)
                    .font(.system(size: 16, weight: .bold))
                //.foregroundColor(.blue)
                Text(name ?? "(unknown group name)")
                //.font(.subheadline)
                //.padding(.leading)
            }
        default:
            Text(name ?? "(unknown group name)")
        }
    }
    
    @ViewBuilder
    func itemNameView(_ data: AccountData) -> some View {
        Text(data.name)
    }
    
    @ViewBuilder
    func itemInfoView(_ data: AccountData) -> some View {
        if vm.accountGroup.choice == .type {
            if let currencyName = vm.currencyList.name.readyValue {
                Text(currencyName[data.currencyId] ?? "")
            }
        } else {
            Text(data.type.rawValue)
        }
    }

    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        AccountFormView(
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.sampleManage {
        AccountListView()
    }
}
