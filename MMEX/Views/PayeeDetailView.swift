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
    
    var body: some View {
        List {
            Section(header: Text("Payee Name")) {
                Text("\(payee.name)")
            }

            Section(header: Text("Category")) {
                Text(payee.categoryId != nil ? getCategoryName(for: payee.categoryId!) : "N/A")
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
                        copyToPasteboard()
                    }
                    Button("Export as JSON File") {
                        exportPayeeToFile()
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
                                isPresentingEditView = false
                                payee = editingPayee
                                saveChanges()
                            }
                        }
                    }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportablePayee(payee: payee),
            contentType: .json,
            defaultFilename: "\(payee.name)_Payee"
        ) { result in
            if case .success(let url) = result {
                exportURL = url
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

    // TODO pre-join via SQL?
    func getCategoryName(for categoryID: Int64) -> String {
        // Find the category with the given ID
        return categories.first { $0.id == categoryID }?.name ?? "Unknown"
    }
    
    // Copy payee details to clipboard as JSON
    func copyToPasteboard() {
        if let jsonData = try? JSONEncoder().encode(payee),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            UIPasteboard.general.string = jsonString
        }
    }
    
    // Export payee details to JSON file
    func exportPayeeToFile() {
        isExporting = true
    }
}

// Struct for exporting payee as a JSON document
struct ExportablePayee: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var payee: Payee
    
    init(payee: Payee) {
        self.payee = payee
    }
    
    init(configuration: ReadConfiguration) throws {
        self.payee = Payee.empty // Initialize with default or empty values
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let jsonData = try JSONEncoder().encode(payee)
        return FileWrapper(regularFileWithContents: jsonData)
    }
}

#Preview {
    PayeeDetailView(payee: Payee.sampleData[0], databaseURL: URL(string: "path/to/database")!, categories: .constant(Category.sampleData))
}

#Preview {
    PayeeDetailView(payee: Payee.sampleData[1], databaseURL: URL(string: "path/to/database")!, categories: .constant(Category.sampleData))
}
