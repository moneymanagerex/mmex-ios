//
//  PayeeDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeDetailView: View {
    @State var payee: Payee
    let databaseURL: URL
    
    @State private var editingPayee = Payee.empty
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    
    var body: some View {
        List {
            Section(header: Text("Payee Name")) {
                Text("\(payee.name)")
            }
            
            Section(header: Text("Category ID")) {
                Text(payee.categoryId != nil ? "\(payee.categoryId!)" : "N/A")
            }

            Section(header: Text("Number")) {
                Text(payee.number ?? "N/A")
            }

            Section(header: Text("Website")) {
                Text(payee.website ?? "N/A")
            }

            Section(header: Text("Notes")) {
                Text(payee.notes ?? "No notes")
            }

            Section(header: Text("Active")) {
                Text(payee.active == 1 ? "Yes" : "No")
            }

            Section(header: Text("Pattern")) {
                Text(payee.pattern.isEmpty ? "No pattern" : payee.pattern)
            }
            // TODO full field
            Button("Delete Payee") {
                deletePayee()
            }
        }
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingPayee = payee
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                PayeeEditView(payee: $editingPayee)
                    .navigationTitle(payee.name)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                payee = editingPayee
                                saveChanges()
                            }
                        }
                    }
            }
        }
    }
    
    func saveChanges() {
        let repository = DataManager(databaseURL: databaseURL).getPayeeRepository() // pass URL here
        if repository.updatePayee(payee: payee) {
            // TODO
        } else {
            // TODO update failure
        }
    }
    
    func deletePayee(){
        let repository = DataManager(databaseURL: databaseURL).getPayeeRepository() // pass URL here
        if repository.deletePayee(payee: payee) {
            // Dismiss the PayeeDetailView and go back to the previous view
            presentationMode.wrappedValue.dismiss()
        } else {
            // TODO
            // handle deletion failure
        }
    }
}
