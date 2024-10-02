//
//  CategoryListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryListView: View {
    @State private var categories: [CategoryData] = []
    @State private var filteredCategories: [CategoryData] = []
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    
    @State private var isPresentingAddView = false
    @State private var newCategory = CategoryData()
    @State private var searchQuery: String = "" // New: Search query
    
    var body: some View {
        NavigationStack {
            List($filteredCategories) { $category in
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
            .searchable(text: $searchQuery, prompt: "Search by name") // New: Search bar
            .onChange(of: searchQuery) { _, query in
                filterCategories(by: query)
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
            let loadedCategories = env.categoryRepository?.load() ?? []
            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.filteredCategories = loadedCategories
            }
        }
    }

    func addCategory(category: inout CategoryData) {
        guard let repository = env.categoryRepository else { return }
        if repository.insert(&category) {
            self.categories.append(category)
        }
    }

    // New: Filter based on the search query
    func filterCategories(by query: String) {
        if query.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
}

#Preview {
    CategoryListView()
        .environmentObject(EnvironmentManager())
}
