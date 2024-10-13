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
    typealias RepositoryData      = RepositoryViewModel.RepositoryData
    typealias RepositoryPartition = RepositoryViewModel.RepositoryPartition

    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var viewModel: RepositoryViewModel
    @State var partition: RepositoryPartition
    @State var search = ""
    @ViewBuilder var groupName: (_ groupId: Int) -> GroupNameView
    @ViewBuilder var itemName: (_ data: RepositoryData) -> ItemNameView
    @ViewBuilder var itemInfo: (_ data: RepositoryData) -> ItemInfoView
    @ViewBuilder var detailView: (_ data: RepositoryData) -> DetailView

    @State var isPresentingAddView = false
    @State var newData = RepositoryViewModel.newData

    var body: some View {
        List {
            HStack {
                Spacer()
                Picker("", selection: $partition) {
                    ForEach(RepositoryPartition.allCases, id: \.self) { p in
                        Text("\(p.rawValue)")
                            .font(.subheadline)
                            .tag(p)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: partition) {
                    viewModel.groupIsReady = false
                    if viewModel.newPartition(partition) {
                        viewModel.groupIsReady = viewModel.newSearch()
                    }
                }
                .padding(.vertical, -5)
                //.border(.red)
            }
            .listRowBackground(Color.clear)
            //.border(.red)
            if viewModel.dataIsReady, viewModel.groupIsReady {
                ForEach(0..<viewModel.group.count, id: \.self) { g in
                    if viewModel.group[g].isVisible {
                        groupView(g)
                    }
                }
            } else if !viewModel.dataIsReady {
                Button(action: { Task {
                    viewModel.groupIsReady = false
                    viewModel.dataIsReady = false
                    viewModel.dataIsReady = await viewModel.loadData()
                    viewModel.groupIsReady = viewModel.newPartition(self.partition)
                } } ) {
                    Text("Load data")
                }
                .listRowBackground(Color.clear)
                .padding()
                .background(.secondary)
                .foregroundColor(.primary)
                .clipShape(Capsule())
            } else if !viewModel.groupIsReady {
                Button(action: {
                    viewModel.groupIsReady = viewModel.newPartition(self.partition)
                } ) {
                    Text("Prepare groups")
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
        .searchable(text: $search, prompt: "Search by name")
        .textInputAutocapitalization(.never)
        .onChange(of: search) { _, newValue in
            viewModel.groupIsReady = false
            viewModel.groupIsReady = viewModel.newSearch(newValue)
        }
        .navigationTitle(RepositoryData.dataName.1)
        .task {
            viewModel.groupIsReady = false
            viewModel.dataIsReady = false
            viewModel.dataIsReady = await viewModel.loadData()
            viewModel.groupIsReady = viewModel.newPartition(self.partition)
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

    func groupView(_ g: Int) -> some View {
        Section(header: HStack {
            Button(action: {
                viewModel.group[g].isExpanded.toggle()
            }) {
                env.theme.group.view(
                    name: { groupName(g) },
                    count: { $0 > 0 ? $0 : nil }(viewModel.group[g].dataId.count),
                    isExpanded: viewModel.group[g].isExpanded
                )
            }
        }//.padding(.top, -10)
        ) {
            if viewModel.group[g].isExpanded {
                ForEach(viewModel.group[g].dataId, id: \.self) { id in
                    // TODO: update View after change in account
                    if viewModel.visible(dataId: id) {
                        itemView(viewModel.dataById[id]!)
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
        viewModel: AccountViewModel(env: EnvironmentManager.sampleData)
    )
    .environmentObject(EnvironmentManager.sampleData)
}
