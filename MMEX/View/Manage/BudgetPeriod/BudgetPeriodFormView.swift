//
//  BudgetPeriodFormView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct BudgetPeriodFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: BudgetPeriodData
    @State var edit: Bool

    var body: some View {
        Section {
            env.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )
        }
    }
}

#Preview("\(BudgetPeriodData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { BudgetPeriodFormView(
        vm: vm,
        data: .constant(BudgetPeriodData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(BudgetPeriodData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { BudgetPeriodFormView(
        vm: vm,
        data: .constant(BudgetPeriodData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
