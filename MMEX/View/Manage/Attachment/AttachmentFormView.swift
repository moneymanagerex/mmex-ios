//
//  AttachmentFormView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AttachmentFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var data: AttachmentData
    @State var edit: Bool

    var body: some View {
        if !data.id.isVoid, !data.refId.isVoid {
            Section {
                pref.theme.field.view(false, "Reference") {
                    Text("\(data.refType.name) #\(data.refId.value)")
                        .opacity(0.5)
                }

                pref.theme.field.view(edit, "Description") {
                    TextField("N/A", text: $data.description)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                }

                // TODO: select file
                pref.theme.field.view(edit, "Filename", editView: {
                    TextField("Shall not be empty!", text: $data.filename)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.words)
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: data.filename)
                } )
            }
        } else {
            Text("New attachments can be created from the items that contain them.")
        }
    }
}

#Preview("\(AttachmentData.sampleData[0].filename) (show)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { AttachmentFormView(
        data: .constant(AttachmentData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}

#Preview("\(AttachmentData.sampleData[0].filename) (edit)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { AttachmentFormView(
        data: .constant(AttachmentData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}
