//
//  PayeeListView.swift
//  MMEX
//
//  2024-09-06: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct PayeeListView: View {
    typealias MainData = PayeeData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    let features = RepositoryFeatures()

    @State var search: PayeeSearch = .init()
    
    static let initData = PayeeData(
        categoryId : -1,
        active     : true
    )
    
    var body: some View {
        RepositoryListView(
            vm: vm,
            features: features,
            vmList: vm.payeeList,
            groupChoice: vm.payeeGroup.choice,
            vmGroup: $vm.payeeGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: PayeeListView.onAppear()")
        }
    }
    
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemNameView(_ data: PayeeData) -> some View {
        Text(data.name)
    }
    
    func itemInfoView(_ data: PayeeData) -> some View {
        Group {
            if vm.payeeGroup.choice == .category {
                Text(data.active ? "Active" : "Inactive")
            } else {
                //Text(vm.categoryList.data.readyValue?[data.categoryId]?.name ?? "")
                Text(vm.categoryList.path.readyValue?[data.categoryId] ?? "")
            }
        }
    }
    
    func editView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        PayeeEditView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    PayeeListView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}
