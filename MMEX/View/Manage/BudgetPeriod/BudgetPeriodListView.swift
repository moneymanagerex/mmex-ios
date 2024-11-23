//
//  BudgetPeriodListView.swift
//  MMEX
//
//  2024-11-22: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetPeriodListView: View {
    typealias MainData = BudgetPeriodData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    
    static let features = RepositoryFeatures()
    static let initData = BudgetPeriodData()

    @State var search: BudgetPeriodSearch = .init()

    var body: some View {
        RepositoryListView(
            vm: vm,
            features: Self.features,
            vmList: vm.budgetPeriodList,
            groupChoice: vm.budgetPeriodGroup.choice,
            vmGroup: $vm.budgetPeriodGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: BudgetPeriodListView.onAppear()")
        }
    }

    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }

    @ViewBuilder
    func itemNameView(_ data: BudgetPeriodData) -> some View {
        Text(data.name)
    }

    @ViewBuilder
    func itemInfoView(_ data: BudgetPeriodData) -> some View {
        EmptyView()
    }

    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        BudgetPeriodFormView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    NavigationView {
        BudgetPeriodListView(
            vm: vm
        )
        .navigationBarTitle("Manage", displayMode: .inline)
    }
    .environmentObject(pref)
    .environmentObject(env)
}
