//
//  PayeeListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State private var payees: [PayeeData] = []
    @State private var filteredPayees: [PayeeData] = [] // New: Filtered payees for search results
    @State private var categories: [CategoryData] = []
    @State private var newPayee = PayeeData()
    @State private var isPresentingPayeeAddView = false
    @State private var searchQuery: String = "" // New: Search query
    
    var body: some View {
        NavigationStack {
            List($filteredPayees) { $payee in // Use filteredPayees instead of payees
                NavigationLink(destination: PayeeDetailView(payee: $payee, categories: $categories)) {
                    HStack {
                        Text(payee.name)
                        Spacer()
                        Text(payee.active ? "ACTIVE" : "INACTIVE")
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingPayeeAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Payee")
            }
            .searchable(text: $searchQuery) // New: Search bar
            .onChange(of: searchQuery, perform: { query in
                filterPayees(by: query)
            })
        }
        .navigationTitle("Payees")
        .onAppear {
            loadPayees()
            loadCategories()
        }
        .sheet(isPresented: $isPresentingPayeeAddView) {
            PayeeAddView(newPayee: $newPayee, isPresentingPayeeAddView: $isPresentingPayeeAddView, categories: $categories) { newPayee in
                addPayee(payee: &newPayee)
                newPayee = PayeeData()
            }
        }
    }
    
    func loadPayees() {
        let repository = dataManager.payeeRepository
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository?.load() ?? []
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
                self.filteredPayees = loadedPayees // Ensure filteredPayees is initialized with all payees
            }
        }
    }

    func loadCategories() {
        let repository = dataManager.categoryRepository

        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository?.load() ?? []

            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }

    func addPayee(payee: inout PayeeData) {
        let repository = dataManager.payeeRepository
        if repository?.insert(&payee) == true {
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
        .environmentObject(DataManager())
}
