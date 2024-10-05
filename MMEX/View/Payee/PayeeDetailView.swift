//
//  PayeeDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import UniformTypeIdentifiers

struct PayeeDetailView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @EnvironmentObject var env: EnvironmentManager
    @Binding var categories: [CategoryData]
    @Binding var payee: PayeeData

    @State private var editPayee = PayeeData()
    @State private var isPresentingEditView = false
    @State private var isExporting = false
    @State private var exportURL: URL?

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        PayeeEditView(
            categories: $categories,
            payee: $payee,
            edit: false
        ) { () in
            deletePayee()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    editPayee = payee
                    isPresentingEditView = true
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
                PayeeEditView(
                    categories: $categories,
                    payee: $editPayee,
                    edit: true
                )
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
                                    payee = editPayee
                                    updatePayee()
                                    isPresentingEditView = false
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
            Alert(
                title: Text("Validation Error"),
                message: Text(alertMessage), dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func updatePayee() {
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
        if editPayee.name.isEmpty {
            alertMessage = "Payee name cannot be empty."
            return false
        }

        // Add more validation logic here if needed (e.g., category selection)
        return true
    }
}

#Preview {
    PayeeDetailView(
        categories: .constant(CategoryData.sampleData),
        payee: .constant(PayeeData.sampleData[0])
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview {
    PayeeDetailView(
        categories: .constant(CategoryData.sampleData),
        payee: .constant(PayeeData.sampleData[1])
    )
    .environmentObject(EnvironmentManager.sampleData)
}
