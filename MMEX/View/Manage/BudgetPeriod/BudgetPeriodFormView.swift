//
//  BudgetPeriodFormView.swift
//  MMEX
//
//  2024-11-22: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetPeriodFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: BudgetPeriodData
    @State var edit: Bool

    var body: some View {
        Section {
            pref.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .keyboardType(pref.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                pref.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )
        }
    }
}

#Preview("\(BudgetPeriodData.sampleData[0].name) (show)") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { BudgetPeriodFormView(
        vm: vm,
        data: .constant(BudgetPeriodData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(env)
}

#Preview("\(BudgetPeriodData.sampleData[0].name) (edit)") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { BudgetPeriodFormView(
        vm: vm,
        data: .constant(BudgetPeriodData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(env)
}
