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
    
    var body: some View {
        List {
            Section(header: Text("Transaction Type")) {
                Text("\(txn.transode)")
            }
            
            // TODO full field
            Button("Delete Transaction") {
                deleteTxn()
            }
        }
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingTxn = txn
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                TransactionEditView(txn: $editingTxn)
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
