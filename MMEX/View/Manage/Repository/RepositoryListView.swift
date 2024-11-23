//
//  RpositoryListView.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryListView<
    ListType: ListProtocol, GroupType: GroupProtocol, SearchType: SearchProtocol,
    GroupNameView: View, ItemNameView: View, ItemInfoView: View,
    FormView: View
>: View
where GroupType.MainRepository == ListType.MainRepository,
      GroupType.ValueType == [GroupData],
      SearchType.MainData == ListType.MainRepository.RepositoryData
{
    typealias MainRepository = ListType.MainRepository
    typealias MainData = MainRepository.RepositoryData
    typealias GroupChoice = GroupType.GroupChoice

    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    var features: RepositoryFeatures
    var vmList: ListType
    @State var groupChoice: GroupChoice
    @Binding var vmGroup: GroupType
    @Binding var search: SearchType
    let initData: MainData
    @ViewBuilder var groupNameView: (_ g: Int, _ name: String?) -> GroupNameView
    @ViewBuilder var itemNameView: (_ data: MainData) -> ItemNameView
    @ViewBuilder var itemInfoView: (_ data: MainData) -> ItemInfoView
    @ViewBuilder var formView: (_ data: Binding<MainData>, _ edit: Bool) -> FormView

    @StateObject var debounce = RepositorySearchDebounce()
    @State var newData: MainData? = nil
    @State var deleteData: Bool = false

    @State private var createSheetIsPresented = false
    @State private var editSheetIsPresented = false
    @State private var editDataId: DataId = .void
    @State private var copySheetIsPresented = false
    @State private var copyDataId: DataId = .void
    @State private var alertIsPresented = false
    @State private var alertMessage: String?

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
                    vm.unloadGroup(GroupType.self)
                    vm.loadGroup(GroupType.self, choice: groupChoice)
                    vm.searchGroup(GroupType.self, search: search)
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

                if features.canSearch {
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
            }
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
            //.border(.red)

            switch vmGroup.state {
            case .ready:
                ForEach(0 ..< vmGroup.value.count, id: \.self) { g in
                    if vmGroup.value[g].isVisible {
                        groupView(g)
                    }
                }
            case .loading:
                HStack {
                    Text("Loading data ...")
                    ProgressView()
                }
            case .error:
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
        //.border(.red)
        .navigationTitle(MainData.dataName.1)

        .toolbar {
            if features.canCreate {
                Button(
                    action: { createSheetIsPresented = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New " + MainData.dataName.0)
            }
        }

        //.modifier(RepositorySearchModifier(
        //    canSearch: features.canSearch, text: $search.key, prompt: search.prompt
        //) )
        .searchable(text: $debounce.input, prompt: search.prompt)
        .textInputAutocapitalization(.never)
        .onChange(of: debounce.output) { _, newValue in
            search.key = newValue
            vmGroup.search = false
            vm.searchGroup(GroupType.self, search: search, expand: true)
        }

        .onAppear {
            if deleteData || newData != nil { return }
            log.debug("DEBUG: RepositoryListView.onAppear()")
            groupChoice = vmGroup.choice
            Task { await load() }
        }

        .refreshable {
            if deleteData || newData != nil { return }
            log.debug("DEBUG: RepositoryListView.refreshable()")
            vm.unloadGroup(GroupType.self)
            vm.unloadList(ListType.self)
            await load()
        }

        .sheet(isPresented: $createSheetIsPresented) {
            RepositoryCreateView(
                vm: vm,
                features: features,
                data: initData,
                newData: $newData,
                isPresented: $createSheetIsPresented,
                formView: formView
            )
            .onDisappear {
                guard newData != nil else { return }
                log.debug("DEBUG: RepositoryListView.RepositoryCreateView.onDisappear()")
                Task {
                    await vm.reload(nil as MainData?, newData)
                    vm.searchGroup(GroupType.self, search: search)
                    newData = nil
                }
            }
        }

        .sheet(isPresented: $editSheetIsPresented) {
            let data = vmList.data.value[editDataId] ?? initData
            RepositoryEditView(
                vm: vm,
                features: features,
                data: data,
                newData: $newData,
                isPresented: $editSheetIsPresented,
                formView: formView
            )
            .onDisappear {
                guard newData != nil else { return }
                log.debug("DEBUG: RepositoryListView.RepositoryEditView.onDisappear")
                Task {
                    await vm.reload(data, newData)
                    vm.searchGroup(GroupType.self, search: search)
                    newData = nil
                }
            }
        }

        .sheet(isPresented: $copySheetIsPresented) {
            let data = vmList.data.value[copyDataId] ?? initData
            RepositoryCopyView(
                vm: vm,
                features: features,
                data: data,
                newData: $newData,
                isPresented: $copySheetIsPresented,
                formView: formView
            )
            .onDisappear {
                guard newData != nil else { return }
                log.debug("DEBUG: RepositoryListView.RepositoryCopyView.onDisappear")
                Task {
                    await vm.reload(nil as MainData?, newData)
                    vm.searchGroup(GroupType.self, search: search)
                    newData = nil
                }
            }
        }

        .alert(isPresented: $alertIsPresented) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage!),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func load() async {
        log.trace("DEBUG: RepositoryListView.load(main=\(Thread.isMainThread))")
        await vm.loadList(ListType.self)
        vm.loadGroup(GroupType.self, choice: groupChoice)
        vm.searchGroup(GroupType.self, search: search)
    }

    func groupView(_ g: Int) -> some View { Group { if vmGroup.state == .ready {
        Section(header: Group {
            if !GroupChoice.isSingleton.contains(vmGroup.choice) {
                HStack {
                    Button(
                        action: { vmGroup.value[g].isExpanded.toggle() }
                    ) {
                        env.theme.group.view(
                            nameView: { groupNameView(g, vmGroup.value[g].name) },
                            count: vmGroup.value[g].dataId.count,
                            isExpanded: vmGroup.value[g].isExpanded
                        )
                    }
                }
            }
        }//.padding(.top, -10)
        ) {
            if vmGroup.value[g].isExpanded {
                switch vmList.data.state {
                case .ready:
                    ForEach(vmGroup.value[g].dataId, id: \.self) { id in
                        if let data = vmList.data.value[id], search.match(vm, data) {
                            itemView(data)
                        }
                    }
                case .loading:
                    HStack {
                        Text("Loading data ...")
                        ProgressView()
                    }
                case .error:
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
        }
    } } }

    @ViewBuilder
    func itemView(_ data: MainData) -> some View {
        NavigationLink(
            destination: RepositoryReadView(
                vm: vm,
                features: features,
                data: data,
                newData: $newData,
                deleteData: $deleteData,
                formView: formView
            )
            .onDisappear {
                guard deleteData || newData != nil else { return }
                log.debug("DEBUG: RepositoryListView.RepositoryReadView.onDisappear")
                Task {
                    await vm.reload(data, newData)
                    vm.searchGroup(GroupType.self, search: search)
                    newData = nil
                    deleteData = false
                }
            }
        ) {
            env.theme.item.view(
                nameView: { itemNameView(data) },
                infoView: { itemInfoView(data) }
            )
        }

        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if features.canDelete { Button {
                guard vm.isUsed(data) == false else { return }
                if let deleteError = vm.delete(data) {
                    alertMessage = deleteError
                    alertIsPresented = true
                } else {
                    Task {
                        await vm.reload(data, nil)
                        vm.searchGroup(GroupType.self, search: search)
                    }
                }
            } label: {
                Label("Delete", systemImage: vm.isUsed(data) == false ? "trash.fill" : "trash.slash.fill")
            }.tint(vm.isUsed(data) == false ? .red : .gray) }

            if features.canEdit { Button {
                editDataId = data.id
                editSheetIsPresented = true
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
            }.tint(.blue) }

            if features.canCopy { Button {
                copyDataId = data.id
                copySheetIsPresented = true
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }.tint(.indigo) }
        }
    }
}

struct RepositorySearchModifier: ViewModifier {
    let canSearch: Bool
    @Binding var text: String
    var prompt: String

    // problem: double copy of content
    // problem: if canSearch == false, an empty area is shown in place of search
    func body(content: Content) -> some View {
        if canSearch {
            content
                .searchable(text: $text, prompt: prompt)
                .textInputAutocapitalization(.never)
        } else {
            content
        }
    }
}

struct RepositorySearchAreaView<RepositoryData: DataProtocol>: View {
    @Binding var area: [SearchArea<RepositoryData>]

    var body: some View {
        List{ Section(header: Text("Search area")) {
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
        } }
    }
}

class RepositorySearchDebounce: ObservableObject {
    @Published var input = ""
    @Published var output = ""

    init() {
        $input
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: &$output)
    }
}

#Preview("Account") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    NavigationView {
        AccountListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
