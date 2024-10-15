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
    DetailView: View, InsertView: View
>: View
{
    typealias RepositoryData    = RepositoryViewModel.RepositoryData
    typealias RepositoryGroupBy = RepositoryViewModel.RepositoryGroupBy

    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: RepositoryViewModel
    @State var groupBy: RepositoryGroupBy
    @ViewBuilder var groupName: (_ groupId: Int) -> GroupNameView
    @ViewBuilder var itemName: (_ data: RepositoryData) -> ItemNameView
    @ViewBuilder var itemInfo: (_ data: RepositoryData) -> ItemInfoView
    @ViewBuilder var detailView: (_ data: RepositoryData) -> DetailView
    @ViewBuilder var addView: (_ isPresented: Binding<Bool>) -> InsertView

    @State var addIsPresented = false

    var body: some View {
        return List {
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
                .onChange(of: groupBy) {
                    vm.loadGroup(env: env, groupBy: groupBy)
                    vm.searchGroup()
                }
                .padding(.vertical, -5)
                //.border(.red)
            }
            .listRowBackground(Color.clear)
            //.border(.red)
            //Text("DEBUG: main=\(Thread.isMainThread), \(vm.dataState.rawValue), \(vm.groupState.rawValue)")
            if vm.dataState == .ready, vm.groupState == .ready {
                ForEach(0..<vm.groupDataId.count, id: \.self) { g in
                    if vm.groupIsVisible[g] {
                        groupView(g)
                    }
                }
            } else {
                Button(action: { Task {
                    await load()
                } } ) {
                    HStack {
                        Text("Loading data ...")
                        ProgressView()
                    }
                }
                .listRowBackground(Color.clear)
                .padding()
                //.background(.secondary)
                .foregroundColor(.secondary)
            }
        }
        //.listStyle(.plain)
        .listSectionSpacing(.compact)
        .toolbar {
            Button(
                action: { addIsPresented = true },
                label: { Image(systemName: "plus") }
            )
            .accessibilityLabel("New " + RepositoryData.dataName.0)
        }
        .searchable(text: $vm.search.key, prompt: "Search by name") // TODO: fix prompt
        .textInputAutocapitalization(.never)
        .onChange(of: vm.search.key) { _, newValue in
            //vm.simpleSearch(with: newValue)
            vm.searchGroup(expand: true)
        }
        .navigationTitle(RepositoryData.dataName.1)
        .onAppear { Task {
            let _ = log.debug("DEBUG: RepositoryListView.onAppear()")
            groupBy = vm.groupBy
            await load()
        } }
        .refreshable {
            vm.unloadData()
            await load()
        }
        .sheet(isPresented: $addIsPresented) {
            addView($addIsPresented)
        }
    }

    private func load() async {
        log.trace("DEBUG: RepositoryListView.load(): main=\(Thread.isMainThread)")
        await vm.loadData(env: env)
        vm.loadGroup(env: env, groupBy: groupBy)
        vm.searchGroup()
        log.trace("INFO: RepositoryListView.load(): \(vm.dataState.rawValue), \(vm.groupState.rawValue)")
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
                    //let _ = print("DEBUG: main=\(Thread.isMainThread), id=\(id), dataState=\(vm.dataState)")
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
}

#Preview("Account") {
    AccountListView(
        vm: AccountViewModel()
    )
    .environmentObject(EnvironmentManager.sampleData)
}
