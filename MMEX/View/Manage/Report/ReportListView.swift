//
//  ReportListView.swift
//  MMEX
//
//  2024-11-23: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct ReportListView: View {
    typealias MainData = ReportData
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = ReportData(
        active: true
    )

    @State var search: ReportSearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.reportList,
            groupChoice: vm.reportGroup.choice,
            vmGroup: $vm.reportGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: ReportListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    @ViewBuilder
    func itemNameView(_ data: ReportData) -> some View {
        Text(data.name)
            .font(.caption)
    }
    
    @ViewBuilder
    func itemInfoView(_ data: ReportData) -> some View {
        switch vm.reportGroup.choice {
        case .group:
            Text(data.active ? "Active" : "Inactive")
        default:
            Text(data.groupName)
        }
    }
    
    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        ReportFormView(
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.sampleManage {
        ReportListView()
    }
}
