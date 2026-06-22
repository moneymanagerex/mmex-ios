//
//  ScheduledListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct ScheduledListView: View {
    typealias MainData = ScheduledData
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = ScheduledData(
        status: .none,
        repeatAuto: .none,
        repeatType: .once
    )

    @State var search: ScheduledSearch = .init()

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.scheduledList,
            groupChoice: vm.scheduledGroup.choice,
            vmGroup: $vm.scheduledGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: ScheduledListView.onAppear()")
        }
    }

    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }

    @ViewBuilder
    func itemNameView(_ data: ScheduledData) -> some View {
        let payeeName = vm.payeeList.data.readyValue?[data.payeeId]?.name ?? "(unknown)"
        let amount = data.transAmount.formatted(
            by: vm.currencyList.info.readyValue?[
                vm.accountList.data.readyValue?[data.accountId]?.currencyId ?? .void
            ]?.formatter
        )
        VStack(alignment: .leading) {
            Text(payeeName)
                .font(.body)
            Text("\(data.transCode.rawValue) • \(amount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    func itemInfoView(_ data: ScheduledData) -> some View {
        let dueDate = data.dueDate.string
        let status = data.status.fullName
        VStack(alignment: .trailing) {
            Text(dueDate)
                .font(.caption)
            Text(status)
                .font(.caption)
                .foregroundColor(status == "(none)" ? .secondary : .accentColor)
        }
    }

    @ViewBuilder
    func formView(_ focus: Binding<Bool>, _ data: Binding<MainData>, _ edit: Bool) -> some View {
        ScheduledFormView(
            focus: focus,
            data: data,
            edit: edit
        )
    }
}

// MARK: - Search

struct ScheduledSearch: SearchProtocol {
    var area: [SearchArea<ScheduledData>] = [
        ("Payee", true, nil, { vm, data in
            vm.payeeList.data.readyValue?[data.payeeId].map { [$0.name] } ?? []
        }),
        ("Account", false, nil, { vm, data in
            vm.accountList.data.readyValue?[data.accountId].map { [$0.name] } ?? []
        }),
        ("Notes", false, {[$0.notes]}, nil),
    ]
    var key: String = ""
}
