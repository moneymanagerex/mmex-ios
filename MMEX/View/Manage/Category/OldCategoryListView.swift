//
//  OldCategoryListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/12.
//

import SwiftUI

struct OldCategoryListView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel

    @State var search: CategorySearch = .init()
    @State var filteredCategories: [DataId] = []

    @State private var isPresentingAddView = false
    @State private var newCategory = CategoryData()
    @State private var searchQuery: String = "" // New: Search query
    
    var body: some View {
        Group {
            List(filteredCategories) { id in
                if let category = vm.categoryList.data.readyValue?[id] {
                    NavigationLink(destination: OldCategoryDetailView(category: category)) {
                        Text(vm.categoryList.evalPath.readyValue?[id] ?? "(unknown)")
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
                filterCategories(by: query)
            }
        }
        .navigationTitle(String(localized: "Categories"))
        .task {
            await vm.loadCategoryList()
            filteredCategories = vm.categoryList.evalTree.readyValue?.order.map { $0.dataId } ?? []
            
            // test
            if false {
                vm.loadCategoryGroup(choice: .used)
                vm.searchCategory(search: search)
                search.key = "an"
                vm.searchCategory(search: search)
                //vm.unloadCategoryGroup()
                //vm.loadCategoryGroup(choice: .notUsed)
            }
        }
        .sheet(isPresented: $isPresentingAddView) {
            OldCategoryAddView(
                newCategory: $newCategory,
                isPresentingAddView: $isPresentingAddView
            ) { newCategory in
                _ = vm.updateCategory(&newCategory)
            }
        }
    }

    func filterCategories(by query: String) {
        filteredCategories = vm.categoryList.evalTree.readyValue?.order.compactMap {
            let id = $0.dataId
            let path = vm.categoryList.evalPath.readyValue?[id]
            return path?.localizedCaseInsensitiveContains(query) == true ? id : nil
        } ?? []
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    OldCategoryListView(
        vm: ViewModel(env: env),
        viewModel: TransactionViewModel(env: env)
    )
    .environmentObject(env)
}