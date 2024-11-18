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

    // new attachments are created from the items that contain them
    static let features = RepositoryFeatures(
        canCreate : false,
        canCopy   : false
    )
    static let initData = AttachmentData(
    )

    @State var search: AttachmentSearch = .init()

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: Self.features,
            vmList: vm.attachmentList,
            groupChoice: vm.attachmentGroup.choice,
            vmGroup: $vm.attachmentGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
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
    
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        AttachmentFormView(
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
        AttachmentListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(env)
}
