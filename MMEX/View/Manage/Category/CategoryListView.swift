//
//  CategoryListView.swift
//  MMEX
//
//  2024-11-17: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = CategoryData(
        active: true
    )

    @State var search: CategorySearch = .init()
    @StateObject var debounce = RepositorySearchDebounce()
    @State var newData: CategoryData? = nil
    @State var deleteData: Bool = false

    @State private var createSheetIsPresented = false
    @State private var editSheetIsPresented = false
    @State private var editDataId: DataId = .void
    @State private var copySheetIsPresented = false
    @State private var copyDataId: DataId = .void
    @State private var alertIsPresented = false
    @State private var alertMessage: String?

    // short names
    var listData    : [DataId: CategoryData]? { vm.categoryList.data.readyValue }
    var evalTree    : CategoryListTree?       { vm.categoryList.evalTree.readyValue }
    var groupChoice : CategoryGroupChoice     { vm.categoryGroup.choice }
    var groupTree   : CategoryGroupTree?      { vm.categoryGroup.readyValue }

    var body: some View {
        List {
            HStack {
                Menu(content: {
                    Picker("", selection: $vm.categoryGroup.choice) {
                        ForEach(CategoryGroupChoice.allCases, id: \.self) { choice in
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
                    vm.unloadCategoryGroup()
                    vm.loadCategoryGroup(choice: groupChoice)
                    vm.searchCategory(search: search)
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

                if Self.features.canSearch {
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

            switch vm.categoryGroup.state {
            case .ready:
                groupView()
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
        .navigationTitle(CategoryData.dataName.1)

        .toolbar {
            if Self.features.canCreate {
                Button(
                    action: { createSheetIsPresented = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New " + CategoryData.dataName.0)
            }
        }

        //.modifier(RepositorySearchModifier(
        //    canSearch: features.canSearch, text: $search.key, prompt: search.prompt
        //) )
        .searchable(text: $debounce.input, prompt: search.prompt)
        .textInputAutocapitalization(.never)
        .onChange(of: debounce.output) { _, newValue in
            search.key = newValue
            vm.categoryGroup.search = false
            vm.searchCategory(search: search)
        }

        .onAppear {
            if deleteData || newData != nil { return }
            log.debug("DEBUG: CategoryListView.onAppear()")
            Task { await load() }
        }

        .refreshable {
            if deleteData || newData != nil { return }
            log.debug("DEBUG: CategoryListView.refreshable()")
            vm.unloadCategoryGroup()
            vm.unloadCategoryList()
            await load()
        }

        .sheet(isPresented: $createSheetIsPresented) {
            RepositoryCreateView(
                vm: vm,
                features: Self.features,
                data: Self.initData,
                newData: $newData,
                isPresented: $createSheetIsPresented,
                formView: formView
            )
            .onDisappear {
                guard newData != nil else { return }
                log.debug("DEBUG: CategoryListView.RepositoryCreateView.onDisappear()")
                Task {
                    await vm.reloadCategoryList(nil as CategoryData?, newData)
                    vm.searchCategory(search: search)
                    newData = nil
                }
            }
        }

        .sheet(isPresented: $editSheetIsPresented) {
            let data = listData?[editDataId] ?? Self.initData
            //let _ = print("DEBUG: editSheetIsPresented: \(editDataId.value)")
            RepositoryEditView(
                vm: vm,
                features: Self.features,
                data: data,
                newData: $newData,
                isPresented: $editSheetIsPresented,
                formView: formView
            )
            .onDisappear {
                guard newData != nil else { return }
                log.debug("DEBUG: CategoryListView.RepositoryEditView.onDisappear")
                Task {
                    await vm.reloadCategoryList(data, newData)
                    vm.searchCategory(search: search)
                    newData = nil
                }
            }
        }

        .sheet(isPresented: $copySheetIsPresented) {
            let data = listData?[copyDataId] ?? Self.initData
            RepositoryCopyView(
                vm: vm,
                features: Self.features,
                data: data,
                newData: $newData,
                isPresented: $copySheetIsPresented,
                formView: formView
            )
            .onDisappear {
                guard newData != nil else { return }
                log.debug("DEBUG: CategoryListView.RepositoryCopyView.onDisappear")
                Task {
                    await vm.reloadCategoryList(nil as CategoryData?, newData)
                    vm.searchCategory(search: search)
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private func load() async {
        log.trace("DEBUG: CategoryListView.load(main=\(Thread.isMainThread))")
        await vm.loadCategoryList()
        vm.loadCategoryGroup(choice: groupChoice)
        vm.searchCategory(search: search)
    }

    @ViewBuilder
    func groupView() -> some View {
        Group { if let listData, let evalTree, let groupTree {
            Section(header: Group { }) {
                ForEach(groupTree.order.indices, id: \.self) { i in
                    let id = evalTree.order[i].dataId
                    if groupTree.order[i].isVisible, let data = listData[id] {
                        itemView(i, data)
                    }
                }
            }
        } }
    }

    @ViewBuilder
    func itemView(_ i: Int, _ data: CategoryData) -> some View {
        Group { if let evalTree, let groupTree {
            NavigationLink(
                destination: RepositoryReadView(
                    vm: vm,
                    features: Self.features,
                    data: data,
                    newData: $newData,
                    deleteData: $deleteData,
                    formView: formView
                )
                .onDisappear {
                    guard deleteData || newData != nil else { return }
                    log.debug("DEBUG: CategoryListView.RepositoryReadView.onDisappear")
                    Task {
                        await vm.reloadCategoryList(data, newData)
                        vm.searchCategory(search: search)
                        newData = nil
                        deleteData = false
                    }
                }
            ) {
                let level  = evalTree.order[i].level
                let member = groupTree.member(i)
                let count  = groupTree.count(i)
                let isExpanded = groupTree.order[i].isExpanded
                HStack {
                    let w1 = CGFloat(28 * level)
                    let w2 = CGFloat(20)
                    Button { if count > 0 {
                        vm.categoryGroup.value.order[i].isExpanded.toggle()
                        vm.expandCategory(i)
                    } } label: {
                        HStack {
                            Spacer().frame(maxWidth: w1)
                            if count > 0 {
                                GroupTheme.fold(isExpanded)
                                    .frame(minWidth: w2)
                                //.border(.red)
                            } else {
                                Spacer().frame(width: w2)
                            }
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(minWidth: w1+w2)
                    //.border(.red)

                    Text(data.name)
                        .font(.headline)
                        .foregroundColor(member == .intermediate ? .gray : .primary)
                    //.padding(.leading)
                    
                    Spacer()
                    if count > 0, !isExpanded {
                        BadgeCount(count: count)
                    }
                }
            }
            
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if Self.features.canDelete { Button {
                    guard vm.isUsed(data) == false else { return }
                    if let deleteError = vm.delete(data) {
                        alertMessage = deleteError
                        alertIsPresented = true
                    } else {
                        Task {
                            await vm.reloadCategoryList(data, nil)
                            vm.searchCategory(search: search)
                        }
                    }
                } label: {
                    Label("Delete", systemImage: vm.isUsed(data) == false ? "trash.fill" : "trash.slash.fill")
                }.tint(vm.isUsed(data) == false ? .red : .gray) }
                
                if Self.features.canEdit { Button {
                    editDataId = data.id
                    //let _ = print("DEBUG: swipeActions: \(editDataId.value)")
                    editSheetIsPresented = true
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }.tint(.blue) }
                
                if Self.features.canCopy { Button {
                    copyDataId = data.id
                    copySheetIsPresented = true
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }.tint(.indigo) }
            }
        } }
    }

    func formView(_ data: Binding<CategoryData>, _ edit: Bool) -> some View {
        CategoryFormView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    NavigationView {
        CategoryListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
