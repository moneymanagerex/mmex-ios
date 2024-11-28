//
//  BudgetFormView.swift
//  MMEX
//
//  2024-11-22: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var data: BudgetData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var baseCurrencyId: DataId? { vm.infotableList.baseCurrencyId.readyValue }
    var formatter: CurrencyFormatter? { baseCurrencyId.map { vm.currencyList.info.readyValue?[$0]?.formatter } ?? nil }

    var body: some View {
        Group {
            Section {
                if
                    let periodOrder = vm.budgetPeriodList.order.readyValue,
                    let periodData  = vm.budgetPeriodList.data.readyValue
                {
                    pref.theme.field.view(edit, false, "Period", editView: {
                        Picker("", selection: $data.periodId) {
                            if data.periodId.isVoid {
                                Text("(none)").tag(DataId.void)
                            }
                            ForEach(periodOrder, id: \.self) { periodId in
                                Text(periodData[periodId]?.name ?? "").tag(periodId)
                            }
                        }
                    }, showView: {
                        pref.theme.field.valueOrHint("N/A", text: periodData[data.periodId]?.name)
                    } )
                }
                
                pref.theme.field.view(edit, true, "Active", editView: {
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
                    pref.theme.field.view(edit, false, "Category", editView: {
                        Picker("", selection: $data.categoryId) {
                            if data.categoryId.isVoid {
                                Text("(none)").tag(DataId.void)
                            }
                            ForEach(categoryOrder, id: \.dataId) { node in
                                Text(categoryPath[node.dataId] ?? "").tag(node.dataId)
                            }
                        }
                    }, showView: {
                        pref.theme.field.valueOrHint("N/A", text: categoryPath[data.categoryId])
                    } )
                }
                
                pref.theme.field.view(edit, false, "Frequency", editView: {
                    Picker("", selection: $data.frequency) {
                        ForEach(BudgetFrequency.allCases, id: \.self) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                }, showView: {
                    pref.theme.field.valueOrHint("N/A", text: data.frequency.rawValue)
                } )
                
                pref.theme.field.view(edit, true, "Flow", editView: {
                    TextField("Negative for outflow", value: $data.flow.defaultZero, format: .number)
                        .focused($focusState, equals: 1)
                        .keyboardType(pref.theme.textPad)
                    //.keyboardType(pref.theme.decimalPad)
                }, showView: {
                    Text(data.flow.formatted(by: formatter))
                } )
            }
            
            Section("Notes") {
                pref.theme.field.notes(edit, "", $data.notes)
                    .focused($focusState, equals: 2)
                    .keyboardType(pref.theme.textPad)
            }
        }
        .onChange(of: focusState) {
            if focusState != nil { focus = true }
        }
        .onChange(of: focus) {
            if focus == false { focusState = nil }
        }
    }
}

#Preview("#\(BudgetData.sampleData[0].id) (show)") {
    MMEXPreview.repositoryEdit { BudgetFormView(
        focus: .constant(false),
        data: .constant(BudgetData.sampleData[0]),
        edit: false
    ) }
}

#Preview("#\(BudgetData.sampleData[0].id) (edit)") {
    MMEXPreview.repositoryEdit { BudgetFormView(
        focus: .constant(false),
        data: .constant(BudgetData.sampleData[0]),
        edit: true
    ) }
}
