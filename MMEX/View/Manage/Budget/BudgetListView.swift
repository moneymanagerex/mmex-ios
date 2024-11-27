//
//  BudgetListView.swift
//  MMEX
//
//  2024-11-22: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetListView: View {
    typealias MainData = BudgetData
    @EnvironmentObject var vm: ViewModel

    static let features = RepositoryFeatures()
    static let initData = BudgetData(
        active: true
    )

    @State var search: BudgetSearch = .init()

    var baseCurrencyId: DataId? { vm.infotableList.baseCurrencyId.readyValue }
    var formatter: CurrencyFormatter? { baseCurrencyId.map { vm.currencyList.info.readyValue?[$0]?.formatter } ?? nil }

    var body: some View {
        RepositoryListView(
            features: Self.features,
            vmList: vm.budgetList,
            groupChoice: vm.budgetGroup.choice,
            vmGroup: $vm.budgetGroup,
            search: $search,
            initData: Self.initData,
            groupNameView: groupNameView,
            itemNameView: itemNameView,
            itemInfoView: itemInfoView,
            formView: formView
        )
        .onAppear {
            let _ = log.debug("DEBUG: BudgetListView.onAppear()")
        }
    }
    
    @ViewBuilder
    func groupNameView(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    @ViewBuilder
    func itemNameView(_ data: BudgetData) -> some View {
        switch vm.budgetGroup.choice {
        case .period:
            Text(vm.categoryList.evalPath.readyValue?[data.categoryId] ?? "(unknown category)")
        default:
            Text(vm.budgetPeriodList.data.readyValue?[data.periodId]?.name ?? "(unknown period)")
        }
    }
    
    @ViewBuilder
    func itemInfoView(_ data: BudgetData) -> some View {
        switch vm.budgetGroup.choice {
        case .period, .category:
            Text(data.flow.formatted(by: formatter) + data.frequency.suffix)
        default:
            Text(vm.categoryList.evalPath.readyValue?[data.categoryId] ?? "(unknown category)")
        }
    }
    
    @ViewBuilder
    func formView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        BudgetFormView(
            data: data,
            edit: edit
        )
    }
}

#Preview {
    MMEXPreview.sampleManage { pref, vm in
        BudgetListView()
    }
}
