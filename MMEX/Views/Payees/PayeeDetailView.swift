//
//  PayeeDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI
import UniformTypeIdentifiers

struct PayeeDetailView: View {
    @State var payee: Payee
    let databaseURL: URL
    @Binding var categories: [Category]
    
    @State private var editingPayee = Payee.empty
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    @State private var isExporting = false
    @State private var exportURL: URL?

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        List {
            Section(header: Text("Payee Name")) {
                Text("\(payee.name)")
            }

            Section(header: Text("Category")) {
                Text(payee.categoryId != 0 ? getCategoryName(for: payee.categoryId!) : "N/A")
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

            Button("Delete Payee") {
                deletePayee()
            }
        }
        .textSelection(.enabled)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditView = true
                    editingPayee = payee
                }
                
                // Export button for pasteboard and external storage
                Menu {
                    Button("Copy to Clipboard") {
                        payee.copyToPasteboard()
                    }
                    Button("Export as JSON File") {
                        isExporting = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                PayeeEditView(payee: $editingPayee, categories: $categories)
                    .navigationTitle(payee.name)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                if validatePayee() {
                                    isPresentingEditView = false
                                    payee = editingPayee
                                    saveChanges()
                                } else {
                                    isShowingAlert = true
                                }
                            }
                        }
                    }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: payee),
            contentType: .json,
            defaultFilename: "\(payee.name)_Payee"
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error exporting file: \(error)")
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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

    // TODO pre-join via SQL?
    func getCategoryName(for categoryID: Int64) -> String {
        // Find the category with the given ID
        return categories.first { $0.id == categoryID }?.name ?? "Unknown"
    }

    func validatePayee() -> Bool {
        if editingPayee.name.isEmpty {
            alertMessage = "Payee name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview {
    PayeeDetailView(payee: Payee.sampleData[0], databaseURL: URL(string: "path/to/database")!, categories: .constant(Category.sampleData))
}

#Preview {
    PayeeDetailView(payee: Payee.sampleData[1], databaseURL: URL(string: "path/to/database")!, categories: .constant(Category.sampleData))
}