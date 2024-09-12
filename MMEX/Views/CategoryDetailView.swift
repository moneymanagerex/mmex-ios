//
//  CategoryDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryDetailView: View {
    @State var category: Category
    let databaseURL: URL
    
    @State private var editingCategory = Category.empty
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    
    var body: some View {
        List {
            Section(header: Text("Category Name")) {
                Text(category.name)
            }
            
            Section(header: Text("Active")) {
                Text(category.active == true ? "Yes" : "No")
            }
            
            Section(header: Text("Parent ID")) {
                Text(category.parentId != nil ? "\(category.parentId!)" : "No Parent")
            }
            
            Button("Delete Category") {
                deleteCategory()
            }
        }
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingCategory = category
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                CategoryEditView(category: $editingCategory)
                    .navigationTitle(category.name)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                category = editingCategory
                                saveChanges()
                            }
                        }
                    }
            }
        }
    }
    
    func saveChanges() {
        let repository = DataManager(databaseURL: databaseURL).getCategoryRepository()
        if repository.updateCategory(category: category) {
            // Handle success
        } else {
            // Handle failure
        }
    }
    
    func deleteCategory() {
        let repository = DataManager(databaseURL: databaseURL).getCategoryRepository()
        if repository.deleteCategory(category: category) {
            // Dismiss the view and go back
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    CategoryDetailView(category: Category.sampleData[0], databaseURL: URL(string: "path/to/database")!)
}
