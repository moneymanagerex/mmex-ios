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
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = PayeeData(
        categoryId : -1,
        active     : true
    )

    @State var search: PayeeSearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.payeeList,
            groupChoice: vm.payeeGroup.choice,
            vmGroup: $vm.payeeGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: PayeeListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    @ViewBuilder
    func itemNameView(_ data: PayeeData) -> some View {
        Text(data.name)
    }
    
    @ViewBuilder
    func itemInfoView(_ data: PayeeData) -> some View {
        if vm.payeeGroup.choice == .category {
            Text(data.active ? "Active" : "Inactive")
        } else {
            //Text(vm.categoryList.data.readyValue?[data.categoryId]?.name ?? "")
            Text(vm.categoryList.evalPath.readyValue?[data.categoryId] ?? "")
        }
    }
    
    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        PayeeFormView(
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.sampleManage {
        PayeeListView()
    }
}
