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
    
    @State var search: PayeeSearch = .init()
    
    static let initData = PayeeData(
        categoryId : -1,
        active     : true
    )
    
    var body: some View {
        RepositoryListView(
            vm: vm,
            vmList: vm.payeeList,
            groupChoice: vm.payeeGroup.choice,
            vmGroup: $vm.payeeGroup,
            search: $search,
            initData: Self.initData,
            groupName: groupName,
            itemName: itemName,
            itemInfo: itemInfo,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: PayeeListView.onAppear()")
        }
    }
    
    func groupName(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemName(_ data: PayeeData) -> some View {
        Text(data.name)
    }
    
    func itemInfo(_ data: PayeeData) -> some View {
        Group {
            if vm.payeeGroup.choice == .category {
                Text(data.active ? "Active" : "Inactive")
            } else {
                //Text(vm.categoryList.data.readyValue?[data.categoryId]?.name ?? "")
                Text(vm.categoryList.path.readyValue?.path[data.categoryId] ?? "")
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
