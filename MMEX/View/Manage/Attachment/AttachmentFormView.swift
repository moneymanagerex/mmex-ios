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
    @Binding var focus: Bool
    @Binding var data: AttachmentData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var body: some View {
        if !data.id.isVoid, !data.refId.isVoid {
            Group {
                Section {
                    pref.theme.field.view(false, "Reference") {
                        Text("\(data.refType.name) #\(data.refId.value)")
                            .opacity(0.5)
                    }
                    
                    pref.theme.field.view(edit, "Description") {
                        TextField("N/A", text: $data.description)
                            .focused($focusState, equals: 1)
                            .keyboardType(pref.theme.textPad)
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    // TODO: select file
                    pref.theme.field.view(edit, "Filename", editView: {
                        TextField("Shall not be empty!", text: $data.filename)
                            .focused($focusState, equals: 2)
                            .keyboardType(pref.theme.textPad)
                            .textInputAutocapitalization(.words)
                    }, showView: {
                        pref.theme.field.valueOrError("Shall not be empty!", text: data.filename)
                    } )
                }
            }
            .onChange(of: focusState) {
                if focusState != nil { focus = true }
            }
            .onChange(of: focus) {
                if focus == false { focusState = nil }
            }
        } else {
            Text("New attachments can be created from the items that contain them.")
        }
    }
}

#Preview("\(AttachmentData.sampleData[0].filename) (show)") {
    MMEXPreview.repositoryEdit { AttachmentFormView(
        focus: .constant(false),
        data: .constant(AttachmentData.sampleData[0]),
        edit: false
    ) }
}

#Preview("\(AttachmentData.sampleData[0].filename) (edit)") {
    MMEXPreview.repositoryEdit { AttachmentFormView(
        focus: .constant(false),
        data: .constant(AttachmentData.sampleData[0]),
        edit: true
    ) }
}
