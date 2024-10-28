//
//  PayeeEditView.swift
//  MMEX
//
//  2024-09-06: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct PayeeEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: PayeeData
    @State var edit: Bool

    var category: String? { vm.categoryList.path.readyValue?.path[data.categoryId] }

    var body: some View {
        Section {
            env.theme.field.text(edit, "Name") {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            } show: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            }
            
            env.theme.field.toggle(edit, "Active") {
                Toggle(isOn: $data.active) { }
            } show: {
                Text(data.active ? "Yes" : "No")
            }
        }
        
        Section {
            if
                let categoryOrder = vm.categoryList.path.readyValue?.order,
                let categoryPath  = vm.categoryList.path.readyValue?.path
            {
                // TODO: category tree
                env.theme.field.picker(edit, "Category") {
                    Picker("", selection: $data.categoryId) {
                        if (data.categoryId <= 0) {
                            Text("Select Category").tag(0 as DataId) // not set
                        }
                        ForEach(categoryOrder, id: \.self) { id in
                            Text(categoryPath[id] ?? "").tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrHint("N/A", text: category)
                }
            }
            
            if edit || !data.number.isEmpty {
                env.theme.field.text(edit, "Payment Number") {
                    TextField("N/A", text: $data.number)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.website.isEmpty {
                env.theme.field.text(edit, "Website") {
                    TextField("N/A", text: $data.website)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.pattern.isEmpty {
                env.theme.field.text(edit, "Pattern") {
                    TextField("N/A", text: $data.pattern)
                        .textInputAutocapitalization(.never)
                }
            }
        }
        
        Section {
            env.theme.field.editor(edit, "Notes") {
                TextEditor(text: $data.notes)
                    .textInputAutocapitalization(.never)
            } show: {
                env.theme.field.valueOrHint("N/A", text: data.notes)
            }
        }
    }
}

#Preview("\(PayeeData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    Form { PayeeEditView(
        vm: ViewModel(env: env),
        data: .constant(PayeeData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(PayeeData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    Form { PayeeEditView(
        vm: ViewModel(env: env),
        data: .constant(PayeeData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
