//
//  CategoryListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryListView: View {
    @State private var categories: [CategoryData] = []
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    
    @State private var isPresentingAddView = false
    @State private var newCategory = CategoryData()
    
    var body: some View {
        NavigationStack {
            List($categories) { $category in
                 NavigationLink(destination: CategoryDetailView(category: $category)) {
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
        let repository = dataManager.getCategoryRepository()
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository.load()

            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }

    func addCategory(category: inout CategoryData) {
        let repository = dataManager.getCategoryRepository()
        if repository.insert(&category) {
            self.categories.append(category)
        }
    }
}

#Preview {
    CategoryListView()
}
