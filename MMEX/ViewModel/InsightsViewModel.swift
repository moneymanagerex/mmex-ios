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

struct InsightsFlow {
    var dataByType: [AccountType: [AccountData]] = [:]
    var today: String = ""
    var flowUntilToday: [DataId: AccountFlowByStatus] = [:]
    var flowAfterToday: [DataId: AccountFlowByStatus] = [:]
}

extension ViewModel {
    func loadInsights() {
        if let baseCurrencyId = InfotableRepository(self.db)?.getValue(for: InfoKey.baseCurrencyID.id, as: DataId.self) {
            baseCurrency = CurrencyRepository(self.db)?.pluck(
                key: InfoKey.baseCurrencyID.id,
                from: CurrencyRepository.table.filter(CurrencyRepository.col_id == Int64(baseCurrencyId))
            ).toOptional()
        }

        // Load transactions on initialization
        loadInsightsFlow()
        loadInsightsRecentTransactions()
        loadInsightsTransactions()

        // Automatically reload transactions when date range changes
        $startDate
            .combineLatest($endDate)
            .sink { [weak self] startDate, endDate in
                self?.loadInsightsRecentTransactions()
            }
            .store(in: &cancellables)
    }
    
    func loadInsightsRecentTransactions() {
        let repository = TransactionRepository(self.db)
        let startDate = self.startDate
        let endDate = self.endDate
        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository?.loadRecent(startDate: startDate, endDate: endDate) ?? []
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.recentStats = transactions
            }
        }
    }
    
    func loadInsightsTransactions() {
        let repository = TransactionRepository(self.db)
        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository?.load() ?? []
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.stats = transactions
            }
        }
    }

    func loadInsightsFlow() {
        self.flow.today = String(endDate.ISO8601Format().prefix(10))
        let repository = AccountRepository(self.db)
        typealias A = AccountRepository
        let table = A.table
            .filter(A.table[A.col_status] == AccountStatus.open.rawValue)

        // fetch open accounts
        DispatchQueue.global(qos: .background).async {
            let dataByType: [AccountType: [AccountData]] = repository?.selectBy(
                property: { row in
                    AccountType(collateNoCase: row[AccountRepository.col_type])
                },
                from: table.order(AccountRepository.col_name)
            ) ?? [:]
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.flow.dataByType = dataByType
            }
        }

        // fetch flow of open accounts until today
        let today = self.flow.today
        DispatchQueue.global(qos: .background).async {
            let flowByStatus = repository?.dictFlowByStatus(
                from: table,
                supDate: today + "z"
            ) ?? [:]
            DispatchQueue.main.async {
                self.flow.flowUntilToday = flowByStatus
            }
        }

        // fetch flow of open accounts after today
        DispatchQueue.global(qos: .background).async {
            let flowByStatus = repository?.dictFlowByStatus(
                from: table,
                minDate: today + "z"
            ) ?? [:]
            DispatchQueue.main.async {
                self.flow.flowAfterToday = flowByStatus
            }
        }
    }
}

extension ViewModel {

    // execute SQL and return its dataset
    func runReport(report: ReportData) -> String {
        if let repo = Repository(self.db) {
            return "\(repo.select(rawQuery: report.sqlContent))"
        } else {
            return ""
        }
    }
}
