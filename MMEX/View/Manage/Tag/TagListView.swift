//
//  TagListView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct TagListView: View {
    typealias MainData = TagData
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = TagData(
        active: true
    )

    @State var search: TagSearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
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
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    @ViewBuilder
    func itemNameView(_ data: TagData) -> some View {
        Text(data.name)
    }
    
    @ViewBuilder
    func itemInfoView(_ data: TagData) -> some View {
        if vm.tagGroup.choice == .active {
            EmptyView()
        } else {
            Text(data.active ? "Active" : "Inactive")
        }
    }
    
    @ViewBuilder
    func formView(_ focus: Binding<Bool>, _ data: Binding<MainData>, _ edit: Bool) -> some View {
        TagFormView(
            focus: focus,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.manageList { pref, vm in
        TagListView()
    }
}
