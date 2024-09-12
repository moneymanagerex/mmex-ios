//
//  CategoryListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryListView: View {
    @State private var categories: [Category] = []
    let databaseURL: URL
    
    @State private var isPresentingAddView = false
    @State private var newCategory = Category.empty

    private var repository: CategoryRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getCategoryRepository()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(category: category, databaseURL: databaseURL)) {
                        Text(category.name)
                    }
                }
            }
            .onAppear(perform: loadCategories)
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingAddView = true
                    }) {
                        Label("Add Category", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddView) {
                NavigationStack {
                    CategoryAddView(newCategory: $newCategory, isPresentingCategoryAddView: $isPresentingAddView) { newAccount in
                        addCategory(category: &newCategory)
                    }
                }
            }
        }
    }
    
    func loadCategories() {
        let repository = DataManager(databaseURL: databaseURL).getCategoryRepository()
        categories = repository.loadCategories()
    }

    func addCategory(category: inout Category) {
        if repository.addCategory(category: &category) {
            self.categories.append(category)
        }
    }
}

#Preview {
    CategoryListView(databaseURL: URL(string: "path/to/database")!)
}
