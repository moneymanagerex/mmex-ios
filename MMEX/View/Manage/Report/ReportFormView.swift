//
//  ReportFormView.swift
//  MMEX
//
//  2024-11-23: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct ReportFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var data: ReportData
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

            pref.theme.field.view(edit, "Group Name", editView: {
                TextField("N/A", text: $data.groupName)
                    .keyboardType(pref.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                pref.theme.field.valueOrHint("N/A", text: data.groupName)
            } )

            pref.theme.field.view(edit, true, "Active", editView: {
                Toggle(isOn: $data.active) { }
            }, showView: {
                Text(data.active ? "Yes" : "No")
            } )
        }

        Section("Description") {
            pref.theme.field.notes(edit, "", $data.description)
                .keyboardType(pref.theme.textPad)
        }

        Section("SQL Content") {
            pref.theme.field.code(edit, "", $data.sqlContent)
                .keyboardType(pref.theme.textPad)
        }

        Section("Lua Content") {
            pref.theme.field.code(edit, "", $data.luaContent)
                .keyboardType(pref.theme.textPad)
        }

        Section("Template Content") {
            pref.theme.field.code(edit, "", $data.templateContent)
                .keyboardType(pref.theme.textPad)
        }
    }
}

#Preview("#\(ReportData.sampleData[0].id) (show)") {
    MMEXPreview.repositoryEdit { ReportFormView(
        data: .constant(ReportData.sampleData[0]),
        edit: false
    ) }
}

#Preview("#\(ReportData.sampleData[0].id) (edit)") {
    MMEXPreview.repositoryEdit { ReportFormView(
        data: .constant(ReportData.sampleData[0]),
        edit: true
    ) }
}
