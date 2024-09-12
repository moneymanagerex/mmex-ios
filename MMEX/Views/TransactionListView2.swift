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
    @State private var payees: [Payee] = []

    private var repository: TransactionRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getTransactionRepository()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(txns_per_day.keys.sorted(by: >), id: \.self) { day in
                    Section(
                        header: HStack {
                            Text(humanReadableDate(day))
                                .font(.headline)
                            Spacer()
                            Text("Total: \(calculateTotal(for: day))")
                                .font(.subheadline)
                        }
                    ) {
                        ForEach(txns_per_day[day]!, id: \.id) { txn in
                            NavigationLink(destination: TransactionDetailView(txn: txn, databaseURL: databaseURL, payees: $payees)) {
                                HStack {
                                    // Left column: Icon (temporary: categID)
                                    Text("\(txn.categID ?? 0)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Middle column: Payee ID and time (hh:mm a format)
                                    VStack(alignment: .leading) {
                                        Text("Payee: \(txn.payeeID)") // Placeholder for actual payee name
                                        Text(formatTime(txn.lastUpdatedTime ?? txn.transDate)) // Show time in hh:mm a
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Right column: Amount
                                    Text(String(format: "%.2f", txn.transAmount ?? 0.0))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadTransactions()
            loadPayees()
        }
    }
    
    func loadTransactions() {
        print("Loading txn in TransactionListView2...")
        
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = repository.loadRecentTransactions()
            
            DispatchQueue.main.async {
                self.txns = loadTransactions
                self.txns_per_day = Dictionary(grouping: txns) { txn in
                    txn.transDate
                }
            }
        }
    }
    
    func loadPayees() {
        let repository = DataManager(databaseURL: self.databaseURL).getPayeeRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository.loadPayees()
            
            DispatchQueue.main.async {
                self.payees = loadedPayees
            }
        }
    }
    
    func calculateTotal(for day: String) -> String {
        let transactions = txns_per_day[day] ?? []
        let totalAmount = transactions.reduce(0.0) { $0 + ( $1.transAmount ?? 0.0) }
        return String(format: "%.2f", totalAmount)
    }

    func humanReadableDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
        }
        return dateString
    }

    func formatTime(_ dateTimeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Assuming the stored format is ISO-8601
        if let dateTime = formatter.date(from: dateTimeString) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: dateTime)
        }
        return dateTimeString // Fallback if parsing fails
    }
}
