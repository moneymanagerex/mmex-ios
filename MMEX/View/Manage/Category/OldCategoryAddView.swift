//
//  OldCategoryAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct OldCategoryAddView: View {
    @Binding var newCategory: CategoryData
    @Binding var isPresentingAddView: Bool

    var onSave: (inout CategoryData) -> Void

    var body: some View {
        NavigationStack {
            OldCategoryEditView(category: $newCategory)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingAddView = false
                            onSave(&newCategory)
                        }
                    }
                }
        }
    }
}
/*
#Preview {
    CategoryAddView(
        newCategory: .constant(CategoryData()),
        isPresentingAddView: .constant(true)
    ) { newCategory in
        // Handle saving in preview
        log.info("New account: \(newCategory.name)")
    }
}
*/
