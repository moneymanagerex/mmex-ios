//
//  InsightsViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SwiftUI
@preconcurrency import SQLite

struct InsightsFlow {
    var dataByType: [AccountType: [AccountData]] = [:]
    var today: String = ""
    var flowUntilToday: [DataId: AccountFlowByStatus] = [:]
    var flowAfterToday: [DataId: AccountFlowByStatus] = [:]
}
@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var baseCurrency: CurrencyData?
    @Published var stats: [TransactionData] = []
    @Published var recentStats: [TransactionData] = []
    @Published var startDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()) {
        didSet { loadInsightsRecentTransactions() }
    }
    @Published var endDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            loadInsightsRecentTransactions()
            loadInsightsFlow()
        }
    }
    @Published var flow = InsightsFlow()

    private var database: SQLite.Connection?
    private var recentRequestID = UUID()

    func load(db: SQLite.Connection?) {
        database = db
        if let baseCurrencyId = InfotableRepository(db)?.getValue(for: InfoKey.baseCurrencyID.id, as: DataId.self) {
            baseCurrency = CurrencyRepository(db)?.pluck(
                key: InfoKey.baseCurrencyID.id,
                from: CurrencyRepository.table.filter(CurrencyRepository.col_id == Int64(baseCurrencyId))
            ).toOptional()
        }
        loadInsightsFlow()
        loadInsightsRecentTransactions()
        loadInsightsTransactions()
    }
    
    func loadInsightsRecentTransactions() {
        guard let database else { return }
        let requestID = UUID()
        recentRequestID = requestID
        let repository = TransactionRepository(database)
        let startDate = self.startDate
        let endDate = self.endDate
        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository.loadRecent(startDate: startDate, endDate: endDate) ?? []
            DispatchQueue.main.async {
                guard self.recentRequestID == requestID else { return }
                self.recentStats = transactions
            }
        }
    }
    
    func loadInsightsTransactions() {
        guard let database else { return }
        let repository = TransactionRepository(database)
        // Fetch transactions asynchronously
        DispatchQueue.global(qos: .background).async {
            let transactions = repository.load() ?? []
            // Update the published stats on the main thread
            DispatchQueue.main.async {
                self.stats = transactions
            }
        }
    }

    private func loadInsightsFlow() {
        guard let database else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.flow.today = formatter.string(from: endDate)
        let repository = AccountRepository(database)
        typealias A = AccountRepository
        let table = A.table
            .filter(A.table[A.col_status] == AccountStatus.open.rawValue)

        // fetch open accounts
        DispatchQueue.global(qos: .background).async {
            let dataByType: [AccountType: [AccountData]] = repository.selectBy(
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
            let flowByStatus = repository.dictFlowByStatus(
                from: table,
                supDate: today + "z"
            ) ?? [:]
            DispatchQueue.main.async {
                self.flow.flowUntilToday = flowByStatus
            }
        }

        // fetch flow of open accounts after today
        DispatchQueue.global(qos: .background).async {
            let flowByStatus = repository.dictFlowByStatus(
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
    func runReport(report: ReportData) -> ReportResult {
        if let repo = Repository(self.db) {
            let (columns, result) = repo.select(rawQuery: report.sqlContent)
            return ReportResult(columnNames: columns, rows: result)
        } else {
            return ReportResult(columnNames: [], rows: [])
        }
    }
}
