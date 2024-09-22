//
//  CategoryAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryAddView: View {
    @Binding var newCategory: Category
    @Binding var isPresentingCategoryAddView: Bool

    var onSave: (inout Category) -> Void

    var body: some View {
        NavigationStack {
            CategoryEditView(category: $newCategory)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingCategoryAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingCategoryAddView = false
                            onSave(&newCategory)
                        }
                    }
                }
        }
    }
}

#Preview {
    CategoryAddView(
        newCategory: .constant(Category()),
        isPresentingCategoryAddView: .constant(true)
    ) { newCategory in
        // Handle saving in preview
        print("New account: \(newCategory.name)")
    }
}
