//
//  RpositoryListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryListView<
    RepositoryViewModel : RepositoryViewModelProtocol,
    GroupNameView: View, ItemNameView: View, ItemInfoView: View,
    DetailView: View
>: View
{
    typealias RepositoryData    = RepositoryViewModel.RepositoryData
    typealias RepositoryGroupBy = RepositoryViewModel.RepositoryGroupBy

    @EnvironmentObject var env: EnvironmentManager
    @Bindable var vm: RepositoryViewModel
    @State var groupBy: RepositoryGroupBy
    @ViewBuilder var groupName: (_ groupId: Int) -> GroupNameView
    @ViewBuilder var itemName: (_ data: RepositoryData) -> ItemNameView
    @ViewBuilder var itemInfo: (_ data: RepositoryData) -> ItemInfoView
    @ViewBuilder var detailView: (_ data: RepositoryData) -> DetailView

    @State var key = ""
    @State var isPresentingAddView = false
    @State var newData = RepositoryViewModel.newData

    var body: some View {
        List {
            HStack {
                Spacer()
                Picker("", selection: $groupBy) {
                    ForEach(RepositoryGroupBy.allCases, id: \.self) { choice in
                        Text("\(choice.rawValue)")
                            .font(.subheadline)
                            .tag(choice)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: groupBy) { Task {
                    vm.loadGroup(groupBy)
                    vm.searchGroup()
                } }
                .padding(.vertical, -5)
                //.border(.red)
            }
            .listRowBackground(Color.clear)
            //.border(.red)
            if vm.dataState == .ready, vm.groupState == .ready {
                ForEach(0..<vm.groupDataId.count, id: \.self) { g in
                    if vm.groupState == .ready && vm.groupIsVisible[g] {
                        groupView(g)
                    }
                }
            } else if vm.dataState == .idle {
                Button(action: { Task {
                    await load()
                } } ) {
                    Text("Load data")
                }
                .listRowBackground(Color.clear)
                .padding()
                .background(.secondary)
                .foregroundColor(.primary)
                .clipShape(Capsule())
            } else if vm.groupState == .idle {
                Button(action: { Task {
                    vm.loadGroup(self.groupBy)
                } } ) {
                    Text("Load groups")
                }
                .listRowBackground(Color.clear)
                .padding()
                .background(.secondary)
                .foregroundColor(.primary)
                .clipShape(Capsule())
            }
        }
        //.listStyle(.plain)
        .listSectionSpacing(.compact)
        .toolbar {
            Button(
                action: { isPresentingAddView = true },
                label: { Image(systemName: "plus") }
            )
            .accessibilityLabel("New " + RepositoryData.dataName.0)
        }
        .searchable(text: $key, prompt: "Search by name") // TODO: fix prompt
        .textInputAutocapitalization(.never)
        .onChange(of: key) { _, newValue in
            vm.simpleSearch(with: newValue)
            vm.searchGroup(expand: true)
        }
        .navigationTitle(RepositoryData.dataName.1)
        .task {
            await load()
        }
        .refreshable {
            await load()
        }
        .sheet(isPresented: $isPresentingAddView) {
/*
            AccountAddView(
                allCurrencyName: $allCurrencyName,
                newAccount: $newAccount,
                isPresentingAddView: $isPresentingAddView
            ) { newAccount in
                addAccount(account: &newAccount)
                newAccount = RepositoryViewModel.newData
            }
 */
        }
    }

    private func load() async {
        await vm.loadData()
        vm.loadGroup(self.groupBy)
    }

    func groupView(_ g: Int) -> some View {
        //Text("group=\(g), \(vm.dataState.rawValue), \(vm.groupState.rawValue)")
        //Text("group=\(g), \(vm.dataById.count), \(vm.groupDataId.count)")

        Section(header: HStack {
            Button(action: {
                vm.groupIsExpanded[g].toggle()
            }) {
                env.theme.group.view(
                    name: { groupName(g) },
                    count: { $0 > 0 ? $0 : nil }(vm.groupDataId[g].count),
                    isExpanded: vm.groupIsExpanded[g]
                )
            }
        }//.padding(.top, -10)
        ) {
            if vm.groupIsExpanded[g] {
                ForEach(vm.groupDataId[g], id: \.self) { id in
                    let _ = print("TEST: main=\(Thread.isMainThread), id=\(id), dataState=\(vm.dataState)")
                    // TODO: update View after change in account
                    if vm.dataIsVisible(id) {
                        itemView(vm.dataById[id]!)
                    }

                }
            }
        }
    }

    func itemView(_ data: RepositoryData) -> some View {
        NavigationLink(destination: detailView(
            data
        ) ) {
            env.theme.item.view(
                name: { itemName(data) },
                info: { itemInfo(data) }
            )
        }
    }

    func addAccount(account: inout AccountData) {
        guard let repository = env.accountRepository else { return }
        if repository.insert(&account) {
            // self.accounts.append(account)
            if env.currencyCache[account.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: account.id, data: account)
            //self.loadAccountData()
        }
    }
}

#Preview("Account") {
    AccountListView(
        vm: AccountViewModel(env: EnvironmentManager.sampleData)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
