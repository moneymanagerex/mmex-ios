//
//  InsightsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/11.
//

import SwiftUI
import Charts

struct InsightsView: View {
    let databaseURL: URL

    // main stats soure, TODO, repalce with dedicated struct
    @State private var stats: [Transaction] = Transaction.sampleData

    // State variables for the date filter
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Date Range Filters
                    Section(header: Text("").font(.headline)) {
                        HStack {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                                .onChange(of: startDate) { newDate in
                                    // TODO
                                }
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date).labelsHidden()
                        }
                        .padding()
                    }

                    Spacer()
                    // line Chart for Transactions Over Time (Filtered by Date)
                    Section(header: Text("").font(.headline)) {
                        Chart(stats) {
                            LineMark(
                                x: .value("Day", $0.day),
                                y: .value("Amount", $0.transAmount ?? 0.0)
                            )
                            .foregroundStyle(by: .value("Status", $0.status.fullName))
                        }
                    }
                }
                .navigationBarTitle("Reports & Insights", displayMode: .inline)
            }
            .padding(.horizontal)
        }
        .onAppear() {
            loadTransactions()
        }
    }

    func loadTransactions() {
        let repository = DataManager(databaseURL: self.databaseURL).getTransactionRepository()

        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = repository.loadRecentTransactions(startDate: startDate, endDate: endDate)

            // Update UI on the main thread
            DispatchQueue.main.async {
                self.stats = loadTransactions
            }
        }
    }
}


#Preview {
    InsightsView(databaseURL: URL(string: "path/to/database")!)
}
