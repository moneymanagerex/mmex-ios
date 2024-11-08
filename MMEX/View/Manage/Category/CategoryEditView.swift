//
//  CategoryEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryEditView: View {
    @Binding var category: CategoryData
    
    var body: some View {
        Form {
            Section(header: Text("Category Name")) {
                TextField("Cannot be empty!", text: $category.name)
            }
            Section(header: Text("ACTIVE")) {
                Toggle("Is Active", isOn: Binding(
                    get: { category.active },
                    set: { category.active = $0 }
                ))
            }
            Section(header: Text("Parent ID")) {
                TextField("Parent ID", value: $category.parentId, formatter: NumberFormatter())
            }
        }
    }
}

#Preview(CategoryData.sampleData[0].name) {
    CategoryEditView(
        category: .constant(CategoryData.sampleData[0])
    )
}
