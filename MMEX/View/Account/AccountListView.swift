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
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel

    @State var search: AccountSearch = .init()

    static let initData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            vmList: vm.accountList,
            groupChoice: vm.accountGroup.choice,
            vmGroup: $vm.accountGroup,
            search: $search,
            initData: Self.initData,
            groupName: groupName,
            itemName: itemName,
            itemInfo: itemInfo,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: AccountListView.onAppear()")
        }
    }
    
    func groupName(_ g: Int, _ name: String?) -> some View {
        Group {
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
    }
    
    func itemName(_ data: AccountData) -> some View {
        Text(data.name)
    }
    
    func itemInfo(_ data: AccountData) -> some View {
        Group {
            if vm.accountGroup.choice == .type {
                if let currencyName = vm.currencyList.name.readyValue {
                    Text(currencyName[data.currencyId] ?? "")
                }
            } else {
                Text(data.type.rawValue)
            }
        }
    }

    func editView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        AccountEditView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    AccountListView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}
