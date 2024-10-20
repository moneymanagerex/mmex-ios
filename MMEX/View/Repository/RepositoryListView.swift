//
//  RpositoryListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryListView<
    RepositoryType: RepositoryProtocol, GroupType: RepositoryLoadGroupProtocol,
    OldRepositoryViewModel : OldRepositoryViewModelProtocol,
    GroupNameView: View, ItemNameView: View, ItemInfoView: View,
    DetailView: View, InsertView: View
>: View
where GroupType.RepositoryType == RepositoryType,
      OldRepositoryViewModel.RepositoryData == RepositoryType.RepositoryData,
      OldRepositoryViewModel.GroupChoiceType == GroupType.GroupChoiceType
{
    typealias RepositoryData  = RepositoryType.RepositoryData
    typealias GroupChoiceType = GroupType.GroupChoiceType

    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: RepositoryViewModel
    var vmData: RepositoryLoadData<RepositoryType>
    var vmDict: RepositoryLoadDataDict<RepositoryType>
    @Binding var vmGroup: GroupType

    @ObservedObject var oldvm: OldRepositoryViewModel
    @State var groupChoice: GroupChoiceType
    @ViewBuilder var groupName: (_ groupId: Int) -> GroupNameView
    @ViewBuilder var itemName: (_ data: RepositoryData) -> ItemNameView
    @ViewBuilder var itemInfo: (_ data: RepositoryData) -> ItemInfoView
    @ViewBuilder var detailView: (_ data: RepositoryData) -> DetailView
    @ViewBuilder var addView: (_ isPresented: Binding<Bool>) -> InsertView

    @State var addIsPresented = false

    var body: some View {
        return List {
            HStack {
                Picker("", selection: $groupChoice) {
                    ForEach(GroupChoiceType.allCases, id: \.self) { choice in
                        Text("\(choice.rawValue)")
                            .font(.subheadline)
                            .tag(choice)
                    }
                }
                .scaledToFit()
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .onChange(of: groupChoice) {
                    vm.loadGroup(for: vmGroup, groupChoice)
                    oldvm.loadGroup(env: env, group: groupChoice)
                    oldvm.searchGroup()
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
                        destination: RepositorySearchAreaView(area: $oldvm.search.area)
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
            switch vmGroup.state {
            case let .ready(dataId):
                ForEach(0 ..< dataId.count, id: \.self) { g in
                    if vmGroup.isVisible[g] {
                        groupView(g)
                    }
                }
            case .loading:
                HStack {
                    Text("Loading data ...")
                    ProgressView()
                }
            case .error(_):
                HStack {
                    Text("Load error ...")
                    ProgressView()
                }.tint(.red)
            case .idle:
                Button(action: { Task {
                    await load()
                } } ) {
                    HStack {
                        Text("Load data")
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
        .searchable(text: $oldvm.search.key, prompt: oldvm.search.prompt)
        .textInputAutocapitalization(.never)
        .onChange(of: oldvm.search.key) { _, newValue in
            oldvm.searchGroup(expand: true)
        }
        .navigationTitle(RepositoryData.dataName.1)
        .onAppear { Task {
            let _ = log.debug("DEBUG: RepositoryListView.onAppear()")
            groupChoice = vmGroup.choice
            await load()
        } }
        .refreshable {
            vm.unloadData(for: vmData)
            oldvm.unloadData()
            await load()
        }
        .sheet(isPresented: $addIsPresented) {
            addView($addIsPresented)
        }
    }

    private func load() async {
        log.trace("DEBUG: RepositoryListView.load(): main=\(Thread.isMainThread)")
        await vm.loadData(for: vmData)
        vm.loadGroup(for: vmGroup, groupChoice)
        await oldvm.loadData(env: env)
        oldvm.loadGroup(env: env, group: groupChoice)
        oldvm.searchGroup()
        log.trace("INFO: RepositoryListView.load(): \(oldvm.dataState.rawValue), \(oldvm.groupState.rawValue)")
    }

    func groupView(_ g: Int) -> some View { Group { if case let .ready(dataId) = vmGroup.state {
        Section(header: Group {
            if !GroupChoiceType.isSingleton.contains(vmGroup.choice) {
                HStack {
                    Button(action: {
                        vmGroup.isExpanded[g].toggle()
                    }) {
                        env.theme.group.view(
                            name: { groupName(g) },
                            count: dataId[g].count,
                            isExpanded: vmGroup.isExpanded[g]
                        )
                    }
                }
            }
        }//.padding(.top, -10)
        ) {
            if vmGroup.isExpanded[g] {
                ForEach(dataId[g], id: \.self) { id in
                    //let _ = print("DEBUG: main=\(Thread.isMainThread), id=\(id), dataState=\(vm.dataState)")
                    // TODO: update View after change in account
                    if /* oldvm.dataIsVisible(id), */ case let .ready(dataDict) = vmDict.state {
                        itemView(dataDict[id]!)
                    }
                    
                }
            }
        }
    } } }

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
    let env = EnvironmentManager.sampleData
    AccountListView(
        vm: RepositoryViewModel(env: env),
        oldvm: AccountViewModel()
    )
    .environmentObject(env)
}
