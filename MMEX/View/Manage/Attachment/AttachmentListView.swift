//
//  AttachmentListView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AttachmentListView: View {
    typealias MainData = AttachmentData
    @EnvironmentObject var vm: ViewModel

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
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }

    @ViewBuilder
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

    @ViewBuilder
    func itemInfoView(_ data: AttachmentData) -> some View {
        EmptyView()
    }
    
    @ViewBuilder
    func formView(_ focus: Binding<Bool>, _ data: Binding<MainData>, _ edit: Bool) -> some View {
        AttachmentFormView(
            focus: focus,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.manageList { pref, vm in
        AttachmentListView()
    }
}
