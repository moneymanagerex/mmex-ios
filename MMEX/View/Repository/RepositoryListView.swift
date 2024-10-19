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
    typealias RepositoryData  = RepositoryViewModel.RepositoryData
    typealias RepositoryGroup = RepositoryViewModel.RepositoryGroup

    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: RepositoryViewModel
    @State var group: RepositoryGroup
    @ViewBuilder var groupName: (_ groupId: Int) -> GroupNameView
    @ViewBuilder var itemName: (_ data: RepositoryData) -> ItemNameView
    @ViewBuilder var itemInfo: (_ data: RepositoryData) -> ItemInfoView
    @ViewBuilder var detailView: (_ data: RepositoryData) -> DetailView
    @ViewBuilder var addView: (_ isPresented: Binding<Bool>) -> InsertView

    @State var addIsPresented = false

    var body: some View {
        return List {
            HStack {
                Picker("", selection: $group) {
                    ForEach(RepositoryGroup.allCases, id: \.self) { choice in
                        Text("\(choice.rawValue)")
                            .font(.subheadline)
                            .tag(choice)
                    }
                }
                .scaledToFit()
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .onChange(of: group) {
                    vm.loadGroup(env: env, group: group)
                    vm.searchGroup()
                }
                .padding(.vertical, -5)
                //.padding(.trailing, 50)
                //.border(.red)
                Button(action: {}){
                    Text("").frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderlessButtonStyle())
                //.border(.red)
                HStack {
                    NavigationLink(
                        destination: RepositorySearchAreaView(area: $vm.search.area)
                    ) {
                        Text("Search area")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        //.border(.red)
                    }
                    //.border(.red)
                }
            }
            .listRowInsets(.init())
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
        .searchable(text: $vm.search.key, prompt: vm.search.prompt)
        .textInputAutocapitalization(.never)
        .onChange(of: vm.search.key) { _, newValue in
            vm.searchGroup(expand: true)
        }
        .navigationTitle(RepositoryData.dataName.1)
        .onAppear { Task {
            let _ = log.debug("DEBUG: RepositoryListView.onAppear()")
            group = vm.group
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
        vm.loadGroup(env: env, group: group)
        vm.searchGroup()
        log.trace("INFO: RepositoryListView.load(): \(vm.dataState.rawValue), \(vm.groupState.rawValue)")
    }

    func groupView(_ g: Int) -> some View {
        Section(header: Group {
            if !RepositoryGroup.isSingleton.contains(vm.group) {
                HStack {
                    Button(action: {
                        vm.groupIsExpanded[g].toggle()
                    }) {
                        env.theme.group.view(
                            name: { groupName(g) },
                            count: vm.groupDataId[g].count,
                            isExpanded: vm.groupIsExpanded[g]
                        )
                    }
                }
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

struct RepositorySearchAreaView<RepositoryData: DataProtocol>: View {
    @Binding var area: [RepositorySearchArea<RepositoryData>]

    var body: some View {
        List{
            Section(header: Text("Search area")) {
                ForEach(0 ..< area.count, id: \.self) { i in
                    Button(action: {
                        area[i].isSelected.toggle()
                        if area.first(where: { $0.isSelected }) == nil { area[0].isSelected = true }
                    } ) {
                        HStack {
                            Text(area[i].name)
                            Spacer()
                            if area[i].isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview("Account") {
    AccountListView(
        vm: AccountViewModel()
    )
    .environmentObject(EnvironmentManager.sampleData)
}
