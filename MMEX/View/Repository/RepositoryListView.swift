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
                    viewModel.newPartition(partition)
                    viewModel.newSearch()
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
            } else {
                Text("Loading data ...")
            }
        }
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
            viewModel.newSearch(newValue)
        }
        .navigationTitle(RepositoryData.dataName.1)
        .task {
            viewModel.dataIsReady = false
            viewModel.dataIsReady = await viewModel.loadData()
            viewModel.newPartition(self.partition)
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
                env.theme.group.hstack(
                    viewModel.group[g].isExpanded
                ) {
                    groupName(g)
                }
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
            HStack {
                itemName(data)
                    .font(.body)
                Spacer()
                itemInfo(data)
                    .font(.caption)
                    //.border(.red)
            }
            .listRowInsets(.init())
            //.border(.red)
            .padding(.horizontal, 0)
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
