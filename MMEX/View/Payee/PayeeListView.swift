//
//  PayeeListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeListView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @State private var payees: [PayeeData] = []
    @State private var filteredPayees: [PayeeData] = [] // New: Filtered payees for search results
    @State private var categories: [CategoryData] = []
    @State private var newPayee = PayeeData()
    @State private var isPresentingAddView = false
    @State private var searchQuery: String = "" // New: Search query
    static let emptyPayee = PayeeData(
        categoryId : -1,
        active     : true
    )

    var body: some View {
        NavigationStack {
            List($filteredPayees) { $payee in // Use filteredPayees instead of payees
                NavigationLink(destination: PayeeDetailView(
                    categories: $categories,
                    payee: $payee
                ) ) {
                    HStack {
                        Text(payee.name)
                        Spacer()
                        Text(payee.active ? "ACTIVE" : "INACTIVE")
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Payee")
            }
            .searchable(text: $searchQuery, prompt: "Search by name") // New: Search bar
            .onChange(of: searchQuery) { _, query in
                filterPayees(by: query)
            }
        }
        .navigationTitle("Payees")
        .onAppear {
            loadPayees()
            loadCategories()
        }
        .sheet(isPresented: $isPresentingAddView) {
            PayeeAddView(
                categories: $categories,
                newPayee: $newPayee,
                isPresentingAddView: $isPresentingAddView
            ) { newPayee in
                addPayee(payee: &newPayee)
                newPayee = Self.emptyPayee
            }
        }
    }
    
    func loadPayees() {
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = env.payeeRepository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
                self.filteredPayees = loadedPayees // Ensure filteredPayees is initialized with all payees
            }
        }
    }

    func loadCategories() {
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = env.categoryRepository?.load() ?? []
            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }

    func addPayee(payee: inout PayeeData) {
        guard let repository = env.payeeRepository else { return }
        if repository.insert(&payee) {
            self.payees.append(payee) // id is ready after repo call
            // loadPayees()
        } else {
            // TODO
        }
    }

    // New: Filter payees based on the search query
    func filterPayees(by query: String) {
        if query.isEmpty {
            filteredPayees = payees
        } else {
            filteredPayees = payees.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
}

#Preview {
    PayeeListView()
        .environmentObject(EnvironmentManager.sampleData)
}
