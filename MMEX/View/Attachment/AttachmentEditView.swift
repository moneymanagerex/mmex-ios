//
//  AttachmentEditView.swift
//  MMEX
//
//  2024-11-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AttachmentEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: AttachmentData
    @State var edit: Bool

    var body: some View {
        if !data.id.isVoid, !data.refId.isVoid {
            Section {
                env.theme.field.text(false, "Reference") {
                    Text("\(data.refType.name) #\(data.refId.value)")
                        .opacity(0.5)
                }

                env.theme.field.text(edit, "Description") {
                    TextField("N/A", text: $data.description)
                        .textInputAutocapitalization(.sentences)
                }

                // TODO: select file
                env.theme.field.text(edit, "Filename") {
                    TextField("Cannot be empty!", text: $data.filename)
                        .textInputAutocapitalization(.words)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: data.filename)
                }
            }
        } else {
            Text("New attachments can be created from the items that contain them.")
        }
    }
}

#Preview("\(AttachmentData.sampleData[0].filename) (show)") {
    let env = EnvironmentManager.sampleData
    Form { AttachmentEditView(
        vm: ViewModel(env: env),
        data: .constant(AttachmentData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(AttachmentData.sampleData[0].filename) (edit)") {
    let env = EnvironmentManager.sampleData
    Form { AttachmentEditView(
        vm: ViewModel(env: env),
        data: .constant(AttachmentData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}