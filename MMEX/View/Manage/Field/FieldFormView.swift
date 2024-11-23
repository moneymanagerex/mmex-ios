//
//  FieldFormView.swift
//  MMEX
//
//  2024-11-23: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct FieldFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: FieldData
    @State var edit: Bool

    var body: some View {
        Section {
            pref.theme.field.view(edit, "Description", editView: {
                TextField("Shall not be empty!", text: $data.description)
                    .keyboardType(pref.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                pref.theme.field.valueOrError("Shall not be empty!", text: data.description)
            } )

            pref.theme.field.view(edit, false, "Reference Type", editView: {
                Picker("", selection: $data.refType) {
                    ForEach(RefType.allCases) { choice in
                        if FieldData.refTypes.contains(choice) {
                            Text(choice.name).tag(choice)
                        }
                    }
                }
            }, showView: {
                Text(data.refType.name)
            } )

            pref.theme.field.view(edit, false, "Field Type", editView: {
                Picker("", selection: $data.type) {
                    if data.type == .unknown {
                        Text("(unknown)").tag(FieldType.unknown)
                    }
                    ForEach(FieldType.allCases) { choice in
                        if choice != .unknown {
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                }
            }, showView: {
                Text(data.type.rawValue)
            } )
        }

        Section("Properties") {
            pref.theme.field.code(edit, "", $data.properties)
                .keyboardType(pref.theme.textPad)
        }
    }
}

#Preview("#\(FieldData.sampleData[0].id) (show)") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { FieldFormView(
        vm: vm,
        data: .constant(FieldData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(env)
}

#Preview("#\(FieldData.sampleData[0].id) (edit)") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { FieldFormView(
        vm: vm,
        data: .constant(FieldData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(env)
}
