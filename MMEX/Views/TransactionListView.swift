//
//  CheckingListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView: View {
    let databaseURL: URL
    @State private var txns: [Transaction] = []
    @State private var newTxn = Transaction.empty
    @State private var isPresentingTransactionAddView = false
    
    private var repository: TransactionRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getTransactionRepository()
    }
    
    var body: some View {
        NavigationStack {
            List(txns) { txn in
                NavigationLink(destination: TransactionDetailView(txn: txn, databaseURL: databaseURL)) {
                    HStack {
                        // Text(txn.transDate, style: .date)
                        Text(txn.transDate)
                        Spacer()
                        Text("\(txn.transcode.id)") // todo name
                        Spacer()
                        Text(String(format: "%.2f", txn.transAmount ?? 0.0))
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingTransactionAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Transaction")
            }
        }
        .onAppear {
            loadTransactions()
        }
        .sheet(isPresented: $isPresentingTransactionAddView) {
            TransactionAddView(newTxn: $newTxn, isPresentingTransactionAddView: $isPresentingTransactionAddView) { newTxn in
                addTransaction(txn: &newTxn)
            }
        }
    }
    
    func loadTransactions() {
        print("Loading txn in TransactionListView...")
        
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = repository.loadTransactions()
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.txns = loadTransactions
            }
        }
    }
    
    func addTransaction(txn: inout Transaction) {
        // TODO
        if self.repository.addTransaction(txn:&txn) {
            self.txns.append(txn) // id is ready after repo call
        } else {
            // TODO
        }
    }
}
