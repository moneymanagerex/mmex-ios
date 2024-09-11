//
//  TransactionAddView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionAddView2: View {
    @State private var transCode: Transcode = .deposit // Default selection
    @State private var amountString: String = "0" // Temporary to store string input for amount
    @State private var selectedDate = Date()
    @State private var selectedCategory = "Category"
    
    @State var newTxn: Transaction = Transaction.empty
    let databaseURL: URL
    @Binding var selectedTab: Int // Bind to the selected tab

    // Dismiss environment action
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            TransactionEditView(txn: $newTxn)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            dismiss()
                            selectedTab = 0
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addTransaction(txn: &newTxn)
                            dismiss()
                            selectedTab = 0
                        }
                    }
                }
        }
        .padding()
        // .navigationBarTitle("Add Transaction", displayMode: .inline)
    }

    func addTransaction(txn: inout Transaction) {
        let repository = DataManager(databaseURL: self.databaseURL).getTransactionRepository()
        if repository.addTransaction(txn:&txn) {
            // id is ready after repo call
        } else {
            // TODO
        }
    }
}
