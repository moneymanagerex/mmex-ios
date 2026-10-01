//
//  OverviewViewModel.swift
//  MMEX
//

import SwiftUI
import SQLite

@MainActor
final class OverviewViewModel: ObservableObject {
    @Published private(set) var transactions: [TransactionData] = []
    @Published private(set) var previousTransactions: [TransactionData] = []
    @Published private(set) var netWorth: Double = 0
    @Published private(set) var previousNetWorth: Double = 0
    @Published private(set) var income: Double = 0
    @Published private(set) var expense: Double = 0
    @Published private(set) var incomeChange: Double = 0
    @Published private(set) var expenseChange: Double = 0
    @Published private(set) var netWorthChange: Double = 0
    @Published private(set) var accountBalances: [DataId: Double] = [:]

    private var refreshTask: Task<Void, Never>?

    func refresh(db: SQLite.Connection?, accounts: [DataId: AccountData], context: AppContext) {
        refreshTask?.cancel()
        let accountId = context.selectedAccountId
        let startDate = context.effectiveStartDate
        let endDate = context.effectiveEndDate
        let previousStart = context.previousPeriodStart
        let previousEnd = context.previousPeriodEnd
        let database = db

        refreshTask = Task { [weak self] in
            guard let self else { return }
            let currentTransactions = await TransactionLoader.load(
                db: database,
                for: accountId.isVoid ? nil : accountId,
                startDate: startDate,
                endDate: endDate
            )
            let oldTransactions = await TransactionLoader.load(
                db: database,
                for: accountId.isVoid ? nil : accountId,
                startDate: previousStart,
                endDate: previousEnd
            )

            guard !Task.isCancelled else { return }
            let balances = await Self.loadAccountBalances(db: database, accounts: accounts)
            guard !Task.isCancelled else { return }

            self.transactions = currentTransactions
            self.previousTransactions = oldTransactions
            self.accountBalances = balances
            self.calculateKPI(from: currentTransactions, previousTransactions: oldTransactions, accounts: accounts)
        }
    }

    private func calculateKPI(from transactions: [TransactionData], previousTransactions: [TransactionData], accounts: [DataId: AccountData]) {
        let income = transactions.filter { $0.transCode == .deposit }.reduce(0) { $0 + $1.transAmount }
        let expense = transactions.filter { $0.transCode == .withdrawal }.reduce(0) { $0 + $1.transAmount }
        let previousIncome = previousTransactions.filter { $0.transCode == .deposit }.reduce(0) { $0 + $1.transAmount }
        let previousExpense = previousTransactions.filter { $0.transCode == .withdrawal }.reduce(0) { $0 + $1.transAmount }

        let worth: Double
        let oldWorth: Double
        if !accountBalances.isEmpty {
            worth = accountBalances.values.reduce(0, +)
            oldWorth = worth - (income - expense - previousIncome + previousExpense)
        } else {
            let initialBalance = accounts.values.reduce(0) { $0 + $1.initialBal }
            worth = income - expense + initialBalance
            oldWorth = previousIncome - previousExpense + initialBalance
        }

        self.income = income
        self.expense = expense
        incomeChange = Self.change(current: income, previous: previousIncome)
        expenseChange = Self.change(current: expense, previous: previousExpense)
        netWorth = worth
        previousNetWorth = oldWorth
        netWorthChange = Self.change(current: worth, previous: oldWorth)
    }

    private static func change(current: Double, previous: Double) -> Double {
        guard previous != 0 else { return 0 }
        return ((current - previous) / abs(previous)) * 100
    }

    private static func loadAccountBalances(db: SQLite.Connection?, accounts: [DataId: AccountData]) async -> [DataId: Double] {
        guard let repository = AccountRepository(db) else { return [:] }
        let today = DateString(Date()).string + "z"
        let flowByAccount = repository.dictFlowByStatus(from: AccountRepository.table, supDate: today) ?? [:]
        return accounts.mapValues { account in
            let accountFlow = flowByAccount[account.id] ?? [:]
            let totalFlow = accountFlow.values.reduce(0) { $0 + ($1.inflow - $1.outflow) }
            return account.initialBal + totalFlow
        }
    }
}
