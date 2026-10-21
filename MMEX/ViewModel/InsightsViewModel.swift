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
    var flowUntilToday: [DataId: AccountFlowByStatus] = [:]
    var flowAfterToday: [DataId: AccountFlowByStatus] = [:]
}

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var baseCurrency: CurrencyData?
    @Published var recentStats: [TransactionData] = []

    @Published var startDate: Date {
        didSet { guard !isBatchUpdating else { return }; reloadRecent() }
    }
    @Published var endDate: Date {
        didSet { guard !isBatchUpdating else { return }; reloadRecent(); reloadFlow() }
    }
    @Published var flow = InsightsFlow()

    // P0 入口
    @Published var budgetSummary: BudgetProgressSummary? = nil
    @Published var budgetIsLoading: Bool = false
    @Published var forecastSummary: CashFlowForecastSummary? = nil
    @Published var forecastIsLoading: Bool = false

    private var database: SQLite.Connection?
    private var recentTask: Task<Void, Never>?
    private var flowTask: Task<Void, Never>?
    private var isBatchUpdating = false

    init() {
        let cal = Calendar.current
        let end = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .month, value: -1, to: end) ?? end
        self.startDate = start
        self.endDate = end
    }

    /// 从 AppContext 批量设置，只触发一次重算
    func setDateRange(start: Date, end: Date) {
        let cal = Calendar.current
        let s = cal.startOfDay(for: start)
        let e = cal.startOfDay(for: end)
        guard s != startDate || e != endDate else { return }
        isBatchUpdating = true
        startDate = s
        endDate = e
        isBatchUpdating = false
        reloadRecent()
        reloadFlow()
    }

    func load(db: SQLite.Connection?, baseCurrencyId: DataId?, currencyInfo: [DataId: CurrencyInfo]?) {
        database = db
        // 不再重复查库，从 vm 已加载的缓存拿
        if let baseCurrencyId, let info = currencyInfo?[baseCurrencyId] {
            baseCurrency = CurrencyData(
                id: baseCurrencyId, name: info.name, prefixSymbol: "", suffixSymbol: "",
                decimalPoint: "", groupSeparator: "", unitName: "", centName: "",
                scale: 0, baseConvRate: info.baseConvRate, symbol: info.symbol,
                type: .fiat
            )
        } else {
            baseCurrency = nil
        }
        reloadFlow()
        reloadRecent()
    }

    // MARK: - Private

    private func reloadRecent() {
        guard let database else { return }
        recentTask?.cancel()
        let start = startDate
        let end = endDate
        recentTask = Task { [weak self] in
            let txns = await Task.detached(priority: .userInitiated) { () -> [TransactionData] in
                let repo = TransactionRepository(database)
                return repo.loadRecent(startDate: start, endDate: end) ?? []
            }.value
            guard !Task.isCancelled else { return }
            self?.recentStats = txns
        }
    }

    private func reloadFlow() {
        guard let database else { return }
        flowTask?.cancel()
        let end = endDate
        let today = DateString(end).string
        flowTask = Task { [weak self] in
            typealias A = AccountRepository
            let table = A.table.filter(A.table[A.col_status] == AccountStatus.open.rawValue)

            let dataByType = await Task.detached(priority: .userInitiated) {
                () -> [AccountType: [AccountData]] in
                let repo = AccountRepository(database)
                return repo.selectBy(
                    property: { row in
                        AccountType(collateNoCase: row[AccountRepository.col_type])
                    },
                    from: table.order(AccountRepository.col_name),
                    with: AccountRepository.fetchData
                ) ?? [:]
            }.value
            guard !Task.isCancelled else { return }

            let until = await Task.detached(priority: .userInitiated) {
                () -> [DataId: AccountFlowByStatus] in
                let repo = AccountRepository(database)
                return repo.dictFlowByStatus(from: table, supDate: today + "z") ?? [:]
            }.value
            guard !Task.isCancelled else { return }

            let after = await Task.detached(priority: .userInitiated) {
                () -> [DataId: AccountFlowByStatus] in
                let repo = AccountRepository(database)
                return repo.dictFlowByStatus(from: table, minDate: today + "z") ?? [:]
            }.value
            guard !Task.isCancelled else { return }

            guard let self else { return }
            self.flow.dataByType = dataByType
            self.flow.flowUntilToday = until
            self.flow.flowAfterToday = after
        }
    }
}

extension ViewModel {
    func runReport(report: ReportData) -> ReportResult {
        if let repo = Repository(self.db) {
            let (columns, result) = repo.select(rawQuery: report.sqlContent)
            return ReportResult(columnNames: columns, rows: result)
        }
        return ReportResult(columnNames: [], rows: [])
    }
}
