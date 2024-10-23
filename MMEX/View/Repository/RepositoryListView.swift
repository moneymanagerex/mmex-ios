//
//  RpositoryListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryListView<
    MainRepository: RepositoryProtocol, GroupType: RepositoryLoadGroupProtocol,
    SearchType: RepositorySearchProtocol,
    GroupNameView: View, ItemNameView: View, ItemInfoView: View,
    DetailView: View, InsertView: View
>: View
where GroupType.MainRepository == MainRepository,
      SearchType.MainData == MainRepository.RepositoryData
{
    typealias MainData  = MainRepository.RepositoryData
    typealias GroupChoice = GroupType.GroupChoice

    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: RepositoryViewModel
    var vmList: RepositoryLoadList<MainRepository>
    var vmData: RepositoryLoadMainData<MainRepository>
    @State var groupChoice: GroupChoice
    @Binding var vmGroup: GroupType
    @Binding var search: SearchType
    @ViewBuilder var groupName: (_ g: Int, _ name: String?) -> GroupNameView
    @ViewBuilder var itemName: (_ data: MainData) -> ItemNameView
    @ViewBuilder var itemInfo: (_ data: MainData) -> ItemInfoView
    @ViewBuilder var createView: (_ newData: Binding<MainData?>, _ isPresented: Binding<Bool>) -> InsertView
    @ViewBuilder var readView: (_ data: MainData, _ newData: Binding<MainData?>, _ deleteData: Binding<Bool>) -> DetailView

    @State var newData: MainData? = nil
    @State var deleteData: Bool = false
    @State var createIsPresented = false

    var body: some View {
        return List {
            HStack {
                Menu(content: {
                    Picker("", selection: $groupChoice) {
                        ForEach(GroupChoice.allCases, id: \.self) { choice in
                            Text("\(choice.fullName)")
                                .font(.subheadline)
                                .tag(choice)
                        }
                    }
                    //.scaledToFit()
                    //.labelsHidden()
                    //.pickerStyle(MenuPickerStyle())
                }, label: { (
                    Text("\(groupChoice.rawValue) ") +
                    Text(Image(systemName: "chevron.up.chevron.down"))
                ) } )
                .onChange(of: groupChoice) {
                    vm.unloadGroup(for: vmGroup)
                    vm.loadGroup(for: vmGroup, groupChoice)
                    vm.searchGroup(for: vmGroup, search: search)
                }
                .padding(.vertical, -5)
                //.padding(.trailing, 50)
                //.border(.red)

                // dummy button in order to force some spacing
                Button(action: {}){
                    Text("").frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderlessButtonStyle())
                //.border(.red)

                HStack {
                    NavigationLink(
                        destination: RepositorySearchAreaView(area: $search.area)
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
            case let .ready(groupData):
                ForEach(0 ..< groupData.count, id: \.self) { g in
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
                action: { createIsPresented = true },
                label: { Image(systemName: "plus") }
            )
            .accessibilityLabel("New " + MainData.dataName.0)
        }
        .searchable(text: $search.key, prompt: search.prompt)
        .textInputAutocapitalization(.never)
        .onChange(of: search.key) { _, newValue in
            vm.searchGroup(for: vmGroup, search: search, expand: true)
        }
        .navigationTitle(MainData.dataName.1)
        .onAppear { Task {
            let _ = log.debug("DEBUG: RepositoryListView.onAppear()")
            groupChoice = vmGroup.choice
            await load()
        } }
        .refreshable {
            vm.unloadGroup(for: vmGroup)
            vm.unloadList(for: vmList)
            await load()
        }
        .sheet(isPresented: $createIsPresented) {
            createView(
                $newData, $createIsPresented
            )
            .onAppear { newData = nil }
            .onDisappear {
                if newData != nil { Task {
                    await vm.reload(nil as MainData?, newData)
                    vm.searchGroup(for: vmGroup, search: search)
                } }
            }
        }
    }

    private func load() async {
        log.trace("DEBUG: RepositoryListView.load(main=\(Thread.isMainThread))")
        await vm.loadList(for: vmList)
        vm.loadGroup(for: vmGroup, groupChoice)
        vm.searchGroup(for: vmGroup, search: search)
    }

    func groupView(_ g: Int) -> some View { Group { if case let .ready(groupData) = vmGroup.state {
        Section(header: Group {
            if !GroupChoice.isSingleton.contains(vmGroup.choice) {
                HStack {
                    Button(
                        action: { vmGroup.isExpanded[g].toggle() }
                    ) {
                        env.theme.group.view(
                            name: { groupName(g, groupData[g].name) },
                            count: groupData[g].dataId.count,
                            isExpanded: vmGroup.isExpanded[g]
                        )
                    }
                }
            }
        }//.padding(.top, -10)
        ) {
            if vmGroup.isExpanded[g] {
                ForEach(groupData[g].dataId, id: \.self) { id in
                    //let _ = print("DEBUG: main=\(Thread.isMainThread), id=\(id), vmData.state=\(vmData.state)")
                    // TODO: update View after change in account
                    if case let .ready(dataDict) = vmData.state,
                       let data = dataDict[id],
                       search.match(data)
                    {
                        itemView(data)
                    }
                    
                }
            }
        }
    } } }

    func itemView(_ data: MainData) -> some View {
        NavigationLink(
            destination: readView(
                data, $newData, $deleteData
            )
            .onAppear {
                newData = nil
                deleteData = false
            }
                .onDisappear { Task {
                    if deleteData || newData != nil {
                        await vm.reload(data, newData)
                        vm.searchGroup(for: vmGroup, search: search)
                    }
                } }
        ) {
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
        vm: RepositoryViewModel(env: env)
    )
    .environmentObject(env)
}
