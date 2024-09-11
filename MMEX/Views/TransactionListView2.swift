//
//  TransactionListView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView2: View {
    let databaseURL: URL
    @State private var txns: [Transaction] = []
    @State private var txns_per_day: [String: [Transaction]] = [:]

    private var repository: TransactionRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getTransactionRepository()
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Loop through sorted transaction dates (days)
                ForEach(txns_per_day.keys.sorted(by: >), id: \.self) { day in
                    Section(header: Text(day).font(.headline)) { // Day as a separator (section header)
                        ForEach(txns_per_day[day]!, id: \.id) { txn in
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
                        }
                    }
                }
            }
        .onAppear {
            loadTransactions()
        }
    }
    
    func loadTransactions() {
        print("Loading txn in TransactionListView2...")
        
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = repository.loadRecentTransactions()
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.txns = loadTransactions
                self.txns_per_day = Dictionary(grouping: txns) { txn in
                    txn.transDate // Format date to a string, e.g., "2024-09-12"
                }
            }
        }
    }
                                           
    func saveChanges(txn: Transaction) {
       let repository = DataManager(databaseURL: databaseURL).getTransactionRepository() // pass URL here
       if repository.updateTransaction(txn: txn) {
           // TODO
       } else {
           // TODO update failure
       }
    }
}
