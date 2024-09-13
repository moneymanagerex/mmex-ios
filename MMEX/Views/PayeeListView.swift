//
//  PayeeListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeListView: View {
    let databaseURL: URL
    @State private var payees: [Payee] = []
    @State private var categories: [Category] = []
    @State private var newPayee = Payee.empty
    @State private var isPresentingPayeeAddView = false
    
    // Initialize repository with the databaseURL
    private var repository: PayeeRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getPayeeRepository() // pass URL here
    }
    
    var body: some View {
        NavigationStack {
            List(payees) { payee in
                NavigationLink(destination: PayeeDetailView(payee: payee, databaseURL: databaseURL, categories: $categories)) {
                    HStack {
                        Text(payee.name)
                        Spacer()
                        Text(payee.active == 1 ? "ACTIVE" : "INACTIVE")
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
        }
        .navigationTitle("Payees")
        .onAppear {
            loadPayees()
            loadCategories()
        }
        .sheet(isPresented: $isPresentingPayeeAddView) {
            PayeeAddView(newPayee: $newPayee, isPresentingPayeeAddView: $isPresentingPayeeAddView, categories: $categories) { newPayee in
                addPayee(payee: &newPayee)
            }
        }
    }
    
    func loadPayees() {
        print("Loading payees in PayeeListView...")
        
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository.loadPayees()
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }

    func loadCategories() {
        let repository = DataManager(databaseURL: self.databaseURL).getCategoryRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository.loadCategories()

            DispatchQueue.main.async {
                self.categories = loadedCategories
            }
        }
    }

    func addPayee(payee: inout Payee) {
        // TODO
        if self.repository.addPayee(payee: &payee) {
            self.payees.append(payee) // id is ready after repo call
            // loadPayees()
        } else {
            // TODO
        }
    }
}

#Preview {
    PayeeListView(databaseURL: URL(string: "path/to/database")!)
}
