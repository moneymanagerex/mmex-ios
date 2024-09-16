//
//  TransactionDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionDetailView: View {
    @State var txn: Transaction
    let databaseURL: URL
    
    @State private var editingTxn = Transaction.empty
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    
    @Binding var payees: [Payee]
    @Binding var categories: [Category]
    @Binding var accounts: [Account]
    
    @State private var account: Account?
    @State private var isExporting = false

    var body: some View {
        List {
            Section(header: Text("Transaction Type")) {
                Text("\(txn.transcode.name)")
            }

            Section(header: Text("Transaction Status")) {
                Text("\(txn.status.fullName)")
            }

            Section(header: Text("Transaction Amount")) {
                if let currency = account?.currency {
                    Text(currency.format(amount: txn.transAmount))
                } else {
                    Text("\(txn.transAmount)")
                }
            }

            Section(header: Text("Transaction Date")) {
                Text(txn.transDate) // Display the transaction date
            }

            Section(header: Text("Account Name")) {
                if let account = account {
                    Text("\(account.name)")
                } else {
                    Text("n/a")
                }
            }

//            Section(header: Text("Payee")) {
//                Text(getPayeeName(txn.payeeID)) // Retrieve payee name
//           }

            Section(header: Text("Notes")) {
                Text(txn.notes ?? "No notes")
            }
            // Section for actions like delete
            Section {
                Button("Delete Transaction") {
                    deleteTxn()
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingTxn = txn
            }
            // Export button for pasteboard and external storage
            Menu {
                Button("Copy to Clipboard") {
                    txn.copyToPasteboard()
                }
                Button("Export as JSON File") {
                    isExporting = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                TransactionEditView(txn: $editingTxn, payees: $payees, categories: $categories, accounts: $accounts)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                txn = editingTxn
                                saveChanges()
                            }
                        }
                    }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: txn),
            contentType: .json,
            defaultFilename: String(format: "%d_Transaction", txn.id)
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error exporting file: \(error)")
            }
        }
        .onAppear(){
            loadAccount()
        }
    }
    
    func loadAccount() {
        account = accounts.first { $0.id == txn.accountID}
    }
    func saveChanges() {
        let repository = DataManager(databaseURL: databaseURL).getTransactionRepository() // pass URL here
        if repository.updateTransaction(txn: txn) {
            // TODO
        } else {
            // TODO update failure
        }
    }
    
    func deleteTxn(){
        let repository = DataManager(databaseURL: databaseURL).getTransactionRepository() // pass URL here
        if repository.deleteTransaction(txn: txn) {
            // Dismiss the TransactionDetailView and go back to the previous view
            presentationMode.wrappedValue.dismiss()
        } else {
            // TODO
            // handle deletion failure
        }
    }
}

#Preview {
    TransactionDetailView(txn: Transaction.sampleData[0], databaseURL: URL(string: "path/to/database")!
                          , payees: .constant(Payee.sampleData), categories: .constant(Category.sampleData)
                          , accounts: .constant(Account.sampleData))
}
