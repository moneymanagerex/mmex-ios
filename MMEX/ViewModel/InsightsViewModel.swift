//
//  InsightsViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SwiftUI
@preconcurrency import SQLite
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.flow.today = formatter.string(from: endDate)
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
    func runReport(report: ReportData) -> ReportResult {
        if let repo = Repository(self.db) {
            let (columns, result) = repo.select(rawQuery: report.sqlContent)
            return ReportResult(columnNames: columns, rows: result)
        } else {
            return ReportResult(columnNames: [], rows: [])
        }
    }
}


extension ViewModel {
    func refreshOverview() {
        let context = AppContext.shared
        let accountId = context.selectedAccountId
        let startDate = context.effectiveStartDate
        let endDate = context.effectiveEndDate
        
        Task {
            let transactions = await loadTransactions(
                db: db,
                for: accountId.isVoid ? nil : accountId,
                startDate: startDate,
                endDate: endDate
            )
            
            let previousStart = context.previousPeriodStart
            let previousEnd = context.previousPeriodEnd
            let previousTransactions = await loadTransactions(
                db: db,
                for: accountId.isVoid ? nil : accountId,
                startDate: previousStart,
                endDate: previousEnd
            )
            
            let balances = await loadAccountBalances()
            
            await MainActor.run {
                self.overviewTransactions = transactions
                self.overviewPreviousTransactions = previousTransactions
                self.accountBalances = balances
                calculateKPI(from: transactions, previousTransactions: previousTransactions, context: context)
            }
        }
    }

    private func calculateKPI(from transactions: [TransactionData], previousTransactions: [TransactionData], context: AppContext) {
        let income = transactions.filter { $0.transCode == .deposit }.reduce(0) { $0 + $1.transAmount }
        let expense = transactions.filter { $0.transCode == .withdrawal }.reduce(0) { $0 + $1.transAmount }
        
        let prevIncome = previousTransactions.filter { $0.transCode == .deposit }.reduce(0) { $0 + $1.transAmount }
        let prevExpense = previousTransactions.filter { $0.transCode == .withdrawal }.reduce(0) { $0 + $1.transAmount }
        
        var netWorth: Double = 0
        var prevNetWorth: Double = 0
        
        if !accountBalances.isEmpty {
            netWorth = accountBalances.values.reduce(0, +)
            prevNetWorth = netWorth - (income - expense - prevIncome + prevExpense)
        } else {
            let initialBalance = accountList.data.readyValue?.values.reduce(0) { $0 + $1.initialBal } ?? 0
            netWorth = income - expense + initialBalance
            prevNetWorth = prevIncome - prevExpense + initialBalance
        }
        
        self.overviewIncome = income
        self.overviewExpense = expense
        self.overviewIncomeChange = calculateChange(current: income, previous: prevIncome)
        self.overviewExpenseChange = calculateChange(current: expense, previous: prevExpense)
        self.overviewNetWorth = netWorth
        self.overviewPreviousNetWorth = prevNetWorth
        self.overviewNetWorthChange = calculateChange(current: netWorth, previous: prevNetWorth)
    }

    private func calculateChange(current: Double, previous: Double) -> Double {
        guard previous != 0 else { return 0 }
        return ((current - previous) / abs(previous)) * 100
    }

    private func loadAccountBalances() async -> [DataId: Double] {
        guard let repo = AccountRepository(db) else { return [:] }
        var balances: [DataId: Double] = [:]
        let today = DateString(Date()).string + "z"
        for (id, account) in accountList.data.readyValue ?? [:] {
            let flow = repo.dictFlowByStatus(from: AccountRepository.table, supDate: today)
            let accountFlow = flow?[id] ?? [:]
            let totalFlow = accountFlow.values.reduce(0) { $0 + ($1.inflow - $1.outflow) }
            balances[id] = account.initialBal + totalFlow
        }
        return balances
    }
}
