//
//  CategoryDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryDetailView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @State var category: CategoryData

    @State private var editingCategory = CategoryData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    
    @State private var isExporting = false

    var body: some View {
        List {
            Section(header: Text("Category Name")) {
                Text(category.name)
            }
            
            Section(header: Text("ACTIVE")) {
                Text(category.active == true ? "YES" : "NO")
            }
            
            // TODO show name and link to its partent
            Section(header: Text("Parent ID")) {
                Text("\(category.parentId.value)")
            }
            
            Button("Delete Category") {
                deleteCategory()
            }
        }
        .textSelection(.enabled)
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingCategory = category
            }
            // Export button for pasteboard and external storage
            Menu {
                Button("Copy to Clipboard") {
                    category.copyToPasteboard()
                }
                Button("Export as JSON File") {
                    isExporting = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
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
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: category),
            contentType: .json,
            defaultFilename: "\(category.name)_Category"
        ) { result in
            switch result {
            case .success(let url):
                log.info("File saved to: \(url)")
            case .failure(let error):
                log.error("Error exporting file: \(error)")
            }
        }
    }
    
    func saveChanges() {
        let repository = CategoryRepository(env)
        if repository?.update(category) == true {
            // Handle success
        } else {
            // Handle failure
        }
    }
    
    func deleteCategory() {
        let repository = CategoryRepository(env)
        if repository?.delete(category) == true {
            // Dismiss the view and go back
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview(CategoryData.sampleData[0].name) {
    CategoryDetailView(
        category: CategoryData.sampleData[0]
    )
}

#Preview(CategoryData.sampleData[1].name) {
    CategoryDetailView(
        category: CategoryData.sampleData[1]
    )
}
