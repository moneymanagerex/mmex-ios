//
//  ReportFormView.swift
//  MMEX
//
//  2024-11-23: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct ReportFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: ReportData
    @State var edit: Bool

    var body: some View {
        Section {
            env.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .keyboardType(env.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )

            env.theme.field.view(edit, "Group Name", editView: {
                TextField("N/A", text: $data.groupName)
                    .keyboardType(env.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrHint("N/A", text: data.groupName)
            } )

            env.theme.field.view(edit, true, "Active", editView: {
                Toggle(isOn: $data.active) { }
            }, showView: {
                Text(data.active ? "Yes" : "No")
            } )
        }

        Section("Description") {
            env.theme.field.notes(edit, "", $data.description)
                .keyboardType(env.theme.textPad)
        }

        Section("SQL Content") {
            env.theme.field.code(edit, "", $data.sqlContent)
                .keyboardType(env.theme.textPad)
        }

        Section("Lua Content") {
            env.theme.field.code(edit, "", $data.luaContent)
                .keyboardType(env.theme.textPad)
        }

        Section("Template Content") {
            env.theme.field.code(edit, "", $data.templateContent)
                .keyboardType(env.theme.textPad)
        }
    }
}

#Preview("#\(ReportData.sampleData[0].id) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { ReportFormView(
        vm: vm,
        data: .constant(ReportData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("#\(ReportData.sampleData[0].id) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { ReportFormView(
        vm: vm,
        data: .constant(ReportData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
