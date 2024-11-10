//
//  CategoryListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel

    @State private var isPresentingAddView = false
    @State private var newCategory = CategoryData()
    @State private var searchQuery: String = "" // New: Search query
    
    var body: some View {
        Group {
            List($viewModel.filteredCategories) { $category in
                 NavigationLink(destination: CategoryDetailView(category: $category)) {
                     HStack {
                         Text(category.fullName(with: viewModel.categDelimiter))
                         Spacer()
                         Text(category.isRoot ? String(localized: "Root") : String(localized: "Non Root"))
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel(String(localized: "New Category"))
            }
            .searchable(text: $searchQuery, prompt: String(localized: "Search by name")) // New: Search bar
            .onChange(of: searchQuery) { _, query in
                viewModel.filterCategories(by: query)
            }
        }
        .navigationTitle(String(localized: "Categories"))
        .onAppear {
            Task {
                await vm.loadCategoryList()
            }
            viewModel.loadCategories()
        }
        .sheet(isPresented: $isPresentingAddView) {
            CategoryAddView(
                newCategory: $newCategory,
                isPresentingAddView: $isPresentingAddView
            ) { newCategory in
                viewModel.addCategory(category: &newCategory)
            }
        }
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    CategoryListView(
        vm: ViewModel(env: env),
        viewModel: TransactionViewModel(env: env)
    )
    .environmentObject(env)
}
