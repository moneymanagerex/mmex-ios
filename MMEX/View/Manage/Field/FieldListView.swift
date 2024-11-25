//
//  FieldListView.swift
//  MMEX
//
//  2024-11-23: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct FieldListView: View {
    typealias MainData = FieldData
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = FieldData()

    @State var search: FieldSearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.fieldList,
            groupChoice: vm.fieldGroup.choice,
            vmGroup: $vm.fieldGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: FieldListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }

    @ViewBuilder
    func itemNameView(_ data: FieldData) -> some View {
        Text(data.description)
    }

    @ViewBuilder
    func itemInfoView(_ data: FieldData) -> some View {
        switch vm.fieldGroup.choice {
        case .refType:
            Text(data.type.rawValue)
        default:
            Text(data.refType.name)
        }
    }
    
    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        FieldFormView(
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.sampleManage {
        FieldListView()
    }
}
