//
//  CategoryFormView.swift
//  MMEX
//
//  2024-11-17: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CategoryFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var data: CategoryData
    @State var edit: Bool

    var categoryPath : [DataId: String]? { vm.categoryList.evalPath.readyValue }
    var categoryTree : CategoryListTree? { vm.categoryList.evalTree.readyValue }
    var dataIndex    : Int?              { categoryTree?.indexById[data.id] }

    func isDescendant(_ i: Int) -> Bool? {
        guard let dataIndex else { return false }
        guard let categoryOrder = categoryTree?.order else { return nil }
        return i >= dataIndex && i < categoryOrder[dataIndex].next
    }

    var body: some View {
        Section {
            if let categoryPath, let categoryOrder = categoryTree?.order {
                // TODO: hierarchical picker
                pref.theme.field.view(edit, "Parent Category", editView: {
                    Picker("", selection: $data.parentId) {
                        Text("(none)").tag(DataId.void)
                        ForEach(categoryOrder.indices, id: \.self) { i in
                            let node = categoryOrder[i]
                            if isDescendant(i) == false {
                                Text(categoryPath[node.dataId] ?? "").tag(node.dataId)
                            }
                        }
                    }
                }, showView: {
                    pref.theme.field.valueOrHint("(none)", text: categoryPath[data.parentId])
                } )
            }

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

#Preview("\(CategoryData.sampleData[1].name) (show)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { CategoryFormView(
        data: .constant(CategoryData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}

#Preview("\(CategoryData.sampleData[1].name) (edit)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { CategoryFormView(
        data: .constant(CategoryData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}
