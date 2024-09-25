//
//  CategoryListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryListView: View {
    @State private var categories: [CategoryData] = []
    let databaseURL: URL
    
    @State private var isPresentingAddView = false
    @State private var newCategory = CategoryData()

    private var repository: CategoryRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getCategoryRepository()
    }
    
    var body: some View {
        NavigationStack {
            List($categories) { $category in
                 NavigationLink(destination: CategoryDetailView(category: $category, databaseURL: databaseURL)) {
                     HStack {
                         Text(category.name)
                         Spacer()
                         Text(category.isRoot ? "Root" : "Non Root")
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Category")
            }
        }
        .navigationTitle("Categories")
        .onAppear {
            loadCategories()
        }
        .sheet(isPresented: $isPresentingAddView) {
            CategoryAddView(newCategory: $newCategory, isPresentingCategoryAddView: $isPresentingAddView) { newCategory in
                addCategory(category: &newCategory)
            }
        }
    }
    
    func loadCategories() {
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository.load()

            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }

    func addCategory(category: inout CategoryData) {
        if repository.insert(&category) {
            self.categories.append(category)
        }
    }
}

#Preview {
    CategoryListView(
        databaseURL: URL(string: "path/to/database")!
    )
}
