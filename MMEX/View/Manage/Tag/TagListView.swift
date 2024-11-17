//
//  TagListView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct TagListView: View {
    typealias MainData = TagData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    let features = RepositoryFeatures()

    @State var search: TagSearch = .init()
    
    static let initData = TagData(
        active     : true
    )
    
    var body: some View {
        RepositoryListView(
            vm: vm,
            features: features,
            vmList: vm.tagList,
            groupChoice: vm.tagGroup.choice,
            vmGroup: $vm.tagGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: TagListView.onAppear()")
        }
    }
    
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemNameView(_ data: TagData) -> some View {
        Text(data.name)
    }
    
    func itemInfoView(_ data: TagData) -> some View {
        Group {
            if vm.tagGroup.choice == .active {
                EmptyView()
            } else {
                Text(data.active ? "Active" : "Inactive")
            }
        }
    }
    
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        TagFormView(
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
        TagListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
