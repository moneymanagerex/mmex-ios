//
//  AttachmentListView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AttachmentListView: View {
    typealias MainData = AttachmentData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    let features = RepositoryFeatures(
        canCreate : false,
        canCopy   : false
    )
    @State var search: AttachmentSearch = .init()

    // new attachments are created from the items that contain them
    static let initData = AttachmentData(
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: features,
            vmList: vm.attachmentList,
            groupChoice: vm.attachmentGroup.choice,
            vmGroup: $vm.attachmentGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: AttachmentListView.onAppear()")
        }
    }
    
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }

    func itemNameView(_ data: AttachmentData) -> some View {
        // filename may be long
        // to avoid overlap, use VStack and small font size
        VStack(alignment: .leading) {
            Text(data.filename).font(.caption)
            Text(
                vm.attachmentGroup.choice == .refType ?
                data.description : data.refType.name
            ).font(.caption)
        }
    }

    func itemInfoView(_ data: AttachmentData) -> some View {
        EmptyView()
    }
    
    func editView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        AttachmentEditView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    AttachmentListView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}