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
    private var dataManager: DataManager

    // Published properties for the view to observe
    @Published var stats: [TransactionData] = []
    @Published var startDate: Date
    @Published var endDate: Date

    private var cancellables = Set<AnyCancellable>()

    init(dataManager: DataManager) {
        self.dataManager = dataManager
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
        let repository = dataManager.transactionRepository

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
