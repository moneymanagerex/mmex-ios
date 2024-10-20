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
    @ObservedObject var oldvm: AccountViewModel

    @State var search: AccountSearch = .init()

    static let newData = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            vmData: vm.accountData,
            vmDict: vm.accountDict,
            vmGroup: $vm.accountGroup,

            oldvm: oldvm,
            groupChoice: oldvm.groupChoice,
            groupName: groupName,
            itemName: itemName,
            itemInfo: itemInfo,
            detailView: { data in AccountDetailView(
                vm: oldvm,
                data: data
            ) },
            addView: { $isPresented in AccountAddView(
                vm: oldvm,
                isPresented: $isPresented
            ) }
        )
        .onAppear {
            let _ = log.debug("DEBUG: AccountListView.onAppear()")
        }
    }

    func groupName(_ groupId: Int) -> some View {
        Group {
            switch vm.accountGroup.choice {
            case .all:
                Text("All")
            case .used:
                Text(AccountViewModel.groupUsed[groupId] ? "Used" : "Other")
            case .favorite:
                Text(AccountViewModel.groupFavorite[groupId] == .boolTrue ? "Favorite" : "Other")
            case .type:
                HStack {
                    Image(systemName: AccountViewModel.groupType[groupId].symbolName)
                        .frame(minWidth: 10, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        //.foregroundColor(.blue)
                    Text(AccountViewModel.groupType[groupId].rawValue)
                    //.font(.subheadline)
                    //.padding(.leading)
                }
            case .currency:
                Text(env.currencyCache[vm.accountGroup.groupCurrency[groupId]]?.name ?? "ERROR: unknown currency")
            case .status:
                Text(AccountViewModel.groupStatus[groupId].rawValue)
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
        vm: RepositoryViewModel(env: env),
        oldvm: AccountViewModel()
    )
    .environmentObject(env)
}
