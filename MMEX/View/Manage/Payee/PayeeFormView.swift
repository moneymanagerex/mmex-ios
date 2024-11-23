//
//  PayeeFormView.swift
//  MMEX
//
//  2024-09-06: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct PayeeFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: PayeeData
    @State var edit: Bool

    var category: String? { vm.categoryList.evalPath.readyValue?[data.categoryId] }

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
        
        Section {
            if
                let categoryOrder = vm.categoryList.evalTree.readyValue?.order,
                let categoryPath  = vm.categoryList.evalPath.readyValue
            {
                // TODO: hierarchical picker
                pref.theme.field.view(edit, false, "Category", editView: {
                    Picker("", selection: $data.categoryId) {
                        Text("(none)").tag(DataId.void)
                        ForEach(categoryOrder, id: \.dataId) { node in
                            Text(categoryPath[node.dataId] ?? "").tag(node.dataId)
                        }
                    }
                }, showView: {
                    pref.theme.field.valueOrHint("N/A", text: category)
                } )
            }
            
            if edit || !data.number.isEmpty {
                pref.theme.field.view(edit, "Payment Number") {
                    TextField("N/A", text: $data.number)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.website.isEmpty {
                pref.theme.field.view(edit, "Website") {
                    TextField("N/A", text: $data.website)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.pattern.isEmpty {
                pref.theme.field.view(edit, "Pattern") {
                    TextField("N/A", text: $data.pattern)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.never)
                }
            }
        }

        Section("Notes") {
            pref.theme.field.notes(edit, "", $data.notes)
                .keyboardType(pref.theme.textPad)
        }
    }
}

#Preview("\(PayeeData.sampleData[0].name) (show)") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { PayeeFormView(
        vm: vm,
        data: .constant(PayeeData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(env)
}

#Preview("\(PayeeData.sampleData[0].name) (edit)") {
    let pref = Preference()
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { PayeeFormView(
        vm: vm,
        data: .constant(PayeeData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(env)
}
