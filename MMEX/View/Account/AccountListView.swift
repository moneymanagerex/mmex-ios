//
//  AccountListView.swift
//  MMEX
//
//  2024-09-05: Created by Lisheng Guan
//  2024-10-11: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: RepositoryViewModel

    @State var search: AccountSearch = .init()

    static let newData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            vmList: vm.accountList,
            vmData: vm.accountData,
            groupChoice: vm.accountGroup.choice,
            vmGroup: $vm.accountGroup,
            search: $search,
            groupName: groupName,
            itemName: itemName,
            itemInfo: itemInfo,
            detailView: { data in AccountDetailView(
                vm: vm,
                data: data
            ) },
            addView: { $isPresented in AccountAddView(
                vm: vm,
                isPresented: $isPresented
            ) }
        )
        .onAppear {
            let _ = log.debug("DEBUG: AccountListView.onAppear()")
        }
    }

    func groupName(_ g: Int, name: String?) -> some View {
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
                if let currency = env.currencyCache[data.currencyId] {
                    Text(currency.name)
                }
            } else {
                Text(data.type.rawValue)
            }
        }
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    AccountListView(
        vm: RepositoryViewModel(env: env)
    )
    .environmentObject(env)
}
