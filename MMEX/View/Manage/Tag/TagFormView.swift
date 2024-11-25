//
//  TagFormView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct TagFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var data: TagData
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

            pref.theme.field.view(edit, true, "Active", editView: {
                Toggle(isOn: $data.active) { }
            }, showView: {
                Text(data.active ? "Yes" : "No")
            } )
        }
    }
}

#Preview("\(TagData.sampleData[0].name) (show)") {
    MMEXPreview.repositoryEdit { TagFormView(
        data: .constant(TagData.sampleData[0]),
        edit: false
    ) }
}

#Preview("\(TagData.sampleData[0].name) (edit)") {
    MMEXPreview.repositoryEdit { TagFormView(
        data: .constant(TagData.sampleData[0]),
        edit: true
    ) }
}
