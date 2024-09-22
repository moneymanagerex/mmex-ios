//
//  InsightsViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SwiftUI
import Combine

class InsightsViewModel: ObservableObject {
    let databaseURL: URL

    // Published properties for the view to observe
    @Published var stats: [Transaction] = []
    @Published var startDate: Date
    @Published var endDate: Date

    private var cancellables = Set<AnyCancellable>()

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.endDate = Date()

        // Load transactions on initialization
        loadTransactions()

        // Automatically reload transactions when date range changes
        $startDate
            .combineLatest($endDate)
            .sink { [weak self] startDate, endDate in
                self?.loadTransactions()
            }
            .store(in: &cancellables)
    }

    func loadTransactions() {
        let repository = DataManager(databaseURL: self.databaseURL).getTransactionRepository()

        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository.loadRecent(startDate: self.startDate, endDate: self.endDate)

            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.stats = transactions
            }
        }
    }
}
