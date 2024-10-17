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
    @ObservedObject var vm: AccountViewModel

    var body: some View {
        RepositoryListView(
            vm: vm,
            group: vm.group,
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

    func groupName(_ groupId: Int) -> some View {
        Group {
            switch vm.group {
            case .all:
                Text("All")
            case .used:
                Text(AccountViewModel.groupUsed[groupId] ? "Used" : "Other")
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
                Text(env.currencyCache[vm.groupCurrency[groupId]]?.name ?? "ERROR: unknown currency")
            case .status:
                Text(AccountViewModel.groupStatus[groupId].rawValue)
            case .favorite:
                Text(AccountViewModel.groupFavorite[groupId] == .boolTrue ? "Favorite" : "Other")
            }
        }
    }

    func itemName(_ data: AccountData) -> some View {
        Text(data.name)
    }

    func itemInfo(_ data: AccountData) -> some View {
        Group {
            if vm.group == .type {
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
    AccountListView(
        vm: AccountViewModel()
    )
    .environmentObject(EnvironmentManager.sampleData)
}
