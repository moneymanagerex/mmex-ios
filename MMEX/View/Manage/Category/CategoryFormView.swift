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
    @Binding var focus: Bool
    @Binding var data: CategoryData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var categoryPath : [DataId: String]? { vm.categoryList.evalPath.readyValue }
    var categoryTree : CategoryListTree? { vm.categoryList.evalTree.readyValue }
    var dataIndex    : Int?              { categoryTree?.indexById[data.id] }

    func isDescendant(_ i: Int) -> Bool? {
        guard let dataIndex else { return false }
        guard let categoryOrder = categoryTree?.order else { return nil }
        return i >= dataIndex && i < categoryOrder[dataIndex].next
    }

    var body: some View {
        Group {
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
                        .focused($focusState, equals: 1)
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

                pref.theme.field.view(edit, "Category Symbol", editView: {
                    Picker("Symbol", selection: Binding(
                        get: { pref.symbol.category2symbol[data.name] ?? "" },
                        set: { newValue in
                            /// CHECK full name vs name
                            pref.symbol.category2symbol[data.name] = newValue
                        }
                    )) {
                        ForEach(CategoryData.predefinedSymbols, id: \.self) { symbol in
                            Image(systemName: symbol)
                            .tag(symbol)
                        }
                    }
                }, showView: {
                    /// CHECK full name vs name
                    if let symbol = pref.symbol.category2symbol[data.name], !symbol.isEmpty {
                        Image(systemName: symbol)
                    } else {
                        pref.theme.field.valueOrError("No symbol", text: nil)
                    }
                })
            }
        }
        .keyboardState(focus: $focus, focusState: $focusState)
    }
}

#Preview("\(CategoryData.sampleData[1].name) (read)") {
    let data = CategoryData.sampleData[0]
    MMEXPreview.manageRead(data) { $focus, $data, edit in CategoryFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}

#Preview("\(CategoryData.sampleData[1].name) (edit)") {
    let data = CategoryData.sampleData[0]
    MMEXPreview.manageEdit(data) { $focus, $data, edit in CategoryFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}
