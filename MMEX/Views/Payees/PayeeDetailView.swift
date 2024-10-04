//
//  PayeeDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI
import UniformTypeIdentifiers

struct PayeeDetailView: View {
    @Binding var payee: PayeeData
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @Binding var categories: [CategoryData]
    
    @State private var editingPayee = PayeeData()
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
                Text(getCategoryName(for: payee.categoryId))
            }

            Section(header: Text("Number")) {
                Text(payee.number)
            }

            Section(header: Text("Website")) {
                Text(payee.website)
            }

            Section(header: Text("Notes")) {
                Text(payee.notes)
            }

            Section(header: Text("Active")) {
                Text(payee.active ? "Yes" : "No")
            }

            Section(header: Text("Pattern")) {
                Text(payee.pattern)
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
                log.info("File saved to: \(url)")
            case .failure(let error):
                log.error("Error exporting file: \(error)")
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveChanges() {
        let repository = env.payeeRepository // pass URL here
        if repository?.update(payee) == true {
            // TODO
        } else {
            // TODO update failure
        }
    }
    
    func deletePayee(){
        let repository = env.payeeRepository // pass URL here
        if repository?.delete(payee) == true {
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
    PayeeDetailView(
        payee: .constant(PayeeData.sampleData[0]),
        categories: .constant(CategoryData.sampleData)
    )
}

#Preview {
    PayeeDetailView(
        payee: .constant(PayeeData.sampleData[1]),
        categories: .constant(CategoryData.sampleData)
    )
}
