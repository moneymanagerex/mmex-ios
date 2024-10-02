//
//  InsightsViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SwiftUI
import SQLite
import Combine

class InsightsViewModel: ObservableObject {
    private var env: EnvironmentManager

    @Published var baseCurrency: CurrencyData?
    @Published var stats: [TransactionData] = [] // all transactions
    // Published properties for the view to observe
    @Published var recentStats: [TransactionData] = []
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var accountInfo = InsightsAccountInfo()
    
    private var cancellables = Set<AnyCancellable>()

    init(env: EnvironmentManager) {
        self.env = env
        self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.endDate = Date()

        // get base currency
        if let baseCurrencyId = env.infotableRepository?.getValue(for: InfoKey.baseCurrencyID.id, as: Int64.self) {
            baseCurrency = env.currencyRepository?.pluck(
                key: InfoKey.baseCurrencyID.id,
                from: CurrencyRepository.table.filter(CurrencyRepository.col_id == baseCurrencyId)
            )
        }

        // Load transactions on initialization
        loadAccountInfo()
        loadRecentTransactions()
        loadTransactions()

        // Automatically reload transactions when date range changes
        $startDate
            .combineLatest($endDate)
            .sink { [weak self] startDate, endDate in
                self?.loadRecentTransactions()
            }
            .store(in: &cancellables)
    }
    
    func loadRecentTransactions() {
        let repository = env.transactionRepository
        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository?.loadRecent(startDate: self.startDate, endDate: self.endDate) ?? []
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.recentStats = transactions
            }
        }
    }
    
    func loadTransactions() {
        let repository = env.transactionRepository
        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository?.load() ?? []
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.stats = transactions
            }
        }
    }

    func loadAccountInfo() {
        self.accountInfo.today = String(self.endDate.ISO8601Format().prefix(10))
        let repository = env.accountRepository
        typealias A = AccountRepository
        let table = A.table
            .filter(A.table[A.col_status] == AccountStatus.open.rawValue)

        // fetch open accounts
        DispatchQueue.global(qos: .background).async {
            let dataByType = repository?.loadByType(
                from: table.order(AccountRepository.col_name)
            ) ?? [:]
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.accountInfo.dataByType = dataByType
            }
        }

        // fetch flow of open accounts until today
        DispatchQueue.global(qos: .background).async {
            let flowByStatus = repository?.dictFlowByStatus(
                from: table,
                supDate: self.accountInfo.today + "z"
            ) ?? [:]
            DispatchQueue.main.async {
                self.accountInfo.flowUntilToday = flowByStatus
            }
        }

        // fetch flow of open accounts after today
        DispatchQueue.global(qos: .background).async {
            let flowByStatus = repository?.dictFlowByStatus(
                from: table,
                minDate: self.accountInfo.today + "z"
            ) ?? [:]
            DispatchQueue.main.async {
                self.accountInfo.flowAfterToday = flowByStatus
            }
        }
    }
}
