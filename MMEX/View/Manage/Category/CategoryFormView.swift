//
//  CategoryFormView.swift
//  MMEX
//
//  2024-11-17: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CategoryFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: CategoryData
    @State var edit: Bool

    var body: some View {
        Section {
            if
                let categoryOrder = vm.categoryList.evalTree.readyValue?.order,
                let categoryPath  = vm.categoryList.evalPath.readyValue
            {
                // TODO: hierarchical picker
                env.theme.field.view(edit, "Parent Category", editView: {
                    Picker("", selection: $data.parentId) {
                        Text("(none)").tag(DataId.void)
                        ForEach(categoryOrder, id: \.dataId) { node in
                            Text(categoryPath[node.dataId] ?? "").tag(node.dataId)
                        }
                    }
                }, showView: {
                    env.theme.field.valueOrHint("(none)", text: categoryPath[data.parentId])
                } )
            }

            env.theme.field.view(edit, "Name", editView: {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            } )
            
            env.theme.field.view(edit, true, "Active", editView: {
                Toggle(isOn: $data.active) { }
            }, showView: {
                Text(data.active ? "Yes" : "No")
            } )
        }
    }
}

#Preview("\(CategoryData.sampleData[1].name) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { CategoryFormView(
        vm: vm,
        data: .constant(CategoryData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(CategoryData.sampleData[1].name) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { CategoryFormView(
        vm: vm,
        data: .constant(CategoryData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}
