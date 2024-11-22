//
//  BudgetFormView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: BudgetData
    @State var edit: Bool

    var baseCurrencyId: DataId? { vm.infotableList.baseCurrencyId.readyValue }
    var formatter: CurrencyFormatter? { baseCurrencyId.map { vm.currencyList.info.readyValue?[$0]?.formatter } ?? nil }

    var body: some View {
        Section {
            if
                let periodOrder = vm.budgetPeriodList.order.readyValue,
                let periodData  = vm.budgetPeriodList.data.readyValue
            {
                env.theme.field.view(edit, false, "Period", editView: {
                    Picker("", selection: $data.periodId) {
                        if data.periodId.isVoid {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(periodOrder, id: \.self) { periodId in
                            Text(periodData[periodId]?.name ?? "").tag(periodId)
                        }
                    }
                }, showView: {
                    env.theme.field.valueOrHint("N/A", text: periodData[data.periodId]?.name)
                } )
            }

            env.theme.field.view(edit, true, "Active", editView: {
                Toggle(isOn: $data.active) { }
            }, showView: {
                Text(data.active ? "Yes" : "No")
            } )
        }

        Section {
            if
                let categoryOrder = vm.categoryList.evalTree.readyValue?.order,
                let categoryPath  = vm.categoryList.evalPath.readyValue
            {
                // TODO: hierarchical picker
                env.theme.field.view(edit, false, "Category", editView: {
                    Picker("", selection: $data.categoryId) {
                        if data.categoryId.isVoid {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(categoryOrder, id: \.dataId) { node in
                            Text(categoryPath[node.dataId] ?? "").tag(node.dataId)
                        }
                    }
                }, showView: {
                    env.theme.field.valueOrHint("N/A", text: categoryPath[data.categoryId])
                } )
            }

            env.theme.field.view(edit, false, "Frequency", editView: {
                Picker("", selection: $data.frequency) {
                    ForEach(BudgetFrequency.allCases, id: \.self) { choice in
                        Text(choice.rawValue).tag(choice)
                    }
                }
            }, showView: {
                env.theme.field.valueOrHint("N/A", text: data.frequency.rawValue)
            } )

            env.theme.field.view(edit, true, "Flow", editView: {
                TextField("Negative for outflow", value: $data.flow.defaultZero, format: .number)
                    //.keyboardType(env.theme.decimalPad)
            }, showView: {
                Text(data.flow.formatted(by: formatter))
            } )
        }

        Section {
            env.theme.field.notes(edit, "Notes", $data.notes)
        }
    }
}

#Preview("#\(BudgetData.sampleData[0].id) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { BudgetFormView(
        vm: vm,
        data: .constant(BudgetData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("#\(BudgetData.sampleData[0].id) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { BudgetFormView(
        vm: vm,
        data: .constant(BudgetData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
