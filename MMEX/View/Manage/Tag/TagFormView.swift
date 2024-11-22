//
//  TagFormView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct TagFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: TagData
    @State var edit: Bool

    var body: some View {
        Section {
            env.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )

            env.theme.field.view(edit, true, "Active", editView: {
                Toggle(isOn: $data.active) { }
            }, showView: {
                Text(data.active ? "Yes" : "No")
            } )
        }
    }
}

#Preview("\(TagData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { TagFormView(
        vm: vm,
        data: .constant(TagData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(TagData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { TagFormView(
        vm: vm,
        data: .constant(TagData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
