//
//  InsightsViewModel+Extended.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/10/21.
//

import Foundation
import SwiftUI

// MARK: - Budget Models

enum BudgetProgressStatus: Int, Comparable {
    case onTrack = 0, nearLimit = 1, over = 2
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct BudgetProgressItem: Identifiable {
    let id: DataId
    let budget: BudgetData
    let categoryPath: String
    let periodName: String
    let periodRange: DateInterval
    let target: Double      // 本周期目标（绝对值）
    let actual: Double      // 本周期实际（绝对值）
    let isExpense: Bool

    var progress: Double {
        guard target > 0 else { return actual > 0 ? 1 : 0 }
        return min(actual / target, 1.5)
    }
    var isOver: Bool { isExpense ? actual > target : actual < target }
    var variance: Double { isExpense ? actual - target : target - actual }
    var remaining: Double { max(target - actual, 0) }
    var status: BudgetProgressStatus {
        if isOver { return .over }
        if progress >= 0.9 { return .nearLimit }
        return .onTrack
    }
}

struct BudgetProgressSummary {
    let periodId: DataId
    let periodName: String
    let periodRange: DateInterval
    let items: [BudgetProgressItem]
    let totalTarget: Double
    let totalActual: Double
    let overCount: Int
}

// MARK: - Budget Extension

@MainActor
extension InsightsViewModel {
    func loadBudget(from appModel: ViewModel, preferredPeriodId: DataId? = nil) {
        guard
            let budgetData   = appModel.budgetList.data.readyValue,
            let budgetOrder  = appModel.budgetList.order.readyValue,
            let periodData   = appModel.budgetPeriodList.data.readyValue,
            let periodOrder  = appModel.budgetPeriodList.order.readyValue,
            let categoryTree = appModel.categoryList.evalTree.readyValue,
            let categoryPath = appModel.categoryList.evalPath.readyValue,
            let db = appModel.db
        else { self.budgetSummary = nil; return }

        self.budgetIsLoading = true

        let candidates: [(BudgetPeriodData, DateInterval)] = periodOrder.compactMap {
            guard let p = periodData[$0],
                  let r = Self.budgetPeriodRange(from: p.name) else { return nil }
            return (p, r)
        }
        guard !candidates.isEmpty else {
            self.budgetSummary = nil; self.budgetIsLoading = false; return
        }

        let resolved: (BudgetPeriodData, DateInterval)
        if let preferredPeriodId,
           let explicit = candidates.first(where: { $0.0.id == preferredPeriodId }) {
            resolved = explicit
        } else if let active = candidates.first(where: { $0.1.contains(Date()) }) {
            resolved = active
        } else {
            resolved = candidates.last!
        }

        // 精确周期长度：优先按月折算，其次按天折算
        let calendar = Calendar(identifier: .gregorian)
        let exactEnd = resolved.1.end.addingTimeInterval(1)
        let monthDiff = calendar.dateComponents(
            [.month], from: resolved.1.start, to: exactEnd
        ).month ?? 0
        let periodLengthYears: Double
        if monthDiff > 0 {
            periodLengthYears = Double(monthDiff) / 12.0
        } else {
            let dayDiff = calendar.dateComponents(
                [.day], from: resolved.1.start, to: exactEnd
            ).day ?? 1
            periodLengthYears = Double(dayDiff) / 365.25
        }

        struct Snapshot {
            let budget: BudgetData
            let categoryIds: Set<DataId>
            let categoryPath: String
        }
        var snapshots: [Snapshot] = []
        for budgetId in budgetOrder {
            guard let budget = budgetData[budgetId], budget.active else { continue }
            guard budget.periodId == resolved.0.id, !budget.categoryId.isVoid else { continue }
            var ids: Set<DataId> = [budget.categoryId]
            if let idx = categoryTree.indexById[budget.categoryId] {
                let next = categoryTree.order[idx].next
                if idx + 1 < next {
                    for i in (idx + 1)..<next { ids.insert(categoryTree.order[i].dataId) }
                }
            }
            snapshots.append(Snapshot(
                budget: budget, categoryIds: ids,
                categoryPath: categoryPath[budget.categoryId] ?? "(unknown)"
            ))
        }

        let periodId = resolved.0.id
        let periodName = resolved.0.name
        let periodRange = resolved.1

        Task.detached(priority: .userInitiated) {
            let allTxns = TransactionRepository(db)?.load() ?? []

            var items: [BudgetProgressItem] = []
            for snap in snapshots {
                let isExpense = snap.budget.flow < 0
                let code: TransactionType = isExpense ? .withdrawal : .deposit
                let actual = allTxns.reduce(0.0) { sum, txn in
                    guard txn.transCode == code, txn.status != .void else { return sum }
                    guard snap.categoryIds.contains(txn.categId) else { return sum }
                    guard let date = txn.transDate.optDate,
                          periodRange.contains(date) else { return sum }
                    return sum + txn.transAmount
                }
                let timesPerYear = snap.budget.frequency == .none
                    ? 1 : snap.budget.frequency.timesPerYear
                let target = abs(snap.budget.flow) * Double(timesPerYear) * periodLengthYears
                items.append(BudgetProgressItem(
                    id: snap.budget.id, budget: snap.budget,
                    categoryPath: snap.categoryPath,
                    periodName: periodName, periodRange: periodRange,
                    target: target, actual: actual, isExpense: isExpense
                ))
            }
            items.sort { $0.status != $1.status ? $0.status > $1.status : $0.progress > $1.progress }

            let summary = BudgetProgressSummary(
                periodId: periodId, periodName: periodName, periodRange: periodRange,
                items: items,
                totalTarget: items.reduce(0.0) { $0 + $1.target },
                totalActual: items.reduce(0.0) { $0 + $1.actual },
                overCount: items.filter { $0.isOver }.count
            )
            await MainActor.run {
                self.budgetSummary = summary
                self.budgetIsLoading = false
            }
        }
    }

    /// 解析 `BudgetPeriodData.name` 为 `DateInterval`
    static func budgetPeriodRange(from name: String) -> DateInterval? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let calendar = Calendar(identifier: .gregorian)

        if trimmed.count == 4, let year = Int(trimmed), year > 0 {
            var comps = DateComponents(); comps.year = year
            guard let start = calendar.date(from: comps) else { return nil }
            let end = calendar.date(byAdding: .year, value: 1, to: start)!.addingTimeInterval(-1)
            return DateInterval(start: start, end: end)
        }

        if trimmed.count == 7, trimmed[trimmed.index(trimmed.startIndex, offsetBy: 4)] == "Q",
           let year = Int(trimmed.prefix(4)),
           let q = Int(trimmed.suffix(1)), (1...4).contains(q) {
            var comps = DateComponents(); comps.year = year; comps.month = (q - 1) * 3 + 1
            guard let start = calendar.date(from: comps) else { return nil }
            let end = calendar.date(byAdding: .month, value: 3, to: start)!.addingTimeInterval(-1)
            return DateInterval(start: start, end: end)
        }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.isLenient = false
        let formats: [(String, Calendar.Component, Int)] = [
            ("yyyy-MM", .month, 7),
            ("yyyy-MM-dd", .day, 10),
        ]
        for (format, component, length) in formats where trimmed.count == length {
            df.dateFormat = format
            if let date = df.date(from: trimmed) {
                let start = calendar.startOfDay(for: date)
                let end = calendar.date(byAdding: component, value: 1, to: start)!
                    .addingTimeInterval(-1)
                return DateInterval(start: start, end: end)
            }
        }
        return nil
    }
}

// MARK: - Forecast Models

struct CashFlowForecastDay: Identifiable {
    var id: Date { date }
    let date: Date
    let inflow: Double
    let outflow: Double
    var net: Double { inflow - outflow }
}

struct CashFlowForecastItem: Identifiable {
    let id: String
    let scheduledId: DataId
    let date: Date
    let amount: Double
    let isInflow: Bool
    let payeeName: String
    let categoryPath: String
}

struct CashFlowForecastSummary {
    let windowStart: Date
    let windowEnd: Date
    let days: [CashFlowForecastDay]
    let items: [CashFlowForecastItem]
    let totalInflow: Double
    let totalOutflow: Double
    let startingBalance: Double
    var netChange: Double { totalInflow - totalOutflow }
    var projectedBalance: Double { startingBalance + netChange }
}

// MARK: - Forecast Extension

@MainActor
extension InsightsViewModel {
    func loadForecast(from appModel: ViewModel, days: Int = 30, accountId: DataId? = nil) {
        guard
            let scheduledData = appModel.scheduledList.data.readyValue,
            let scheduledOrder = appModel.scheduledList.order.readyValue,
            let accountData = appModel.accountList.data.readyValue,
            let payeeData = appModel.payeeList.data.readyValue,
            let categoryPath = appModel.categoryList.evalPath.readyValue,
            let db = appModel.db
        else { self.forecastSummary = nil; return }

        self.forecastIsLoading = true

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let windowStart = today
        let windowEnd = calendar.date(byAdding: .day, value: days, to: today)!

        let filterAccountId: DataId? = (accountId?.isVoid ?? true) ? nil : accountId
        var scheduled: [ScheduledData] = []
        for id in scheduledOrder {
            guard let s = scheduledData[id], s.status != .void else { continue }
            if let acc = filterAccountId,
               s.accountId != acc && s.toAccountId != acc { continue }
            scheduled.append(s)
        }

        let flow = AccountRepository(db)?.dictFlowByStatus(
            from: AccountRepository.table,
            supDate: DateString(today).string + "z"
        ) ?? [:]
        let startingBalance: Double = {
            let accounts = filterAccountId.flatMap { accountData[$0].map { [$0] } }
                ?? accountData.values.filter { $0.status == .open }
            return accounts.reduce(0.0) { sum, acc in
                let f = flow[acc.id]?.values.reduce(0.0) { $0 + $1.inflow - $1.outflow } ?? 0
                return sum + acc.initialBal + f
            }
        }()

        var items: [CashFlowForecastItem] = []
        for s in scheduled {
            if s.transCode == .transfer { continue }   // 避免双账户重复计入
            let payeeName = payeeData[s.payeeId]?.name ?? "(unknown)"
            let catPath = categoryPath[s.categId] ?? ""
            for date in Self.forecastOccurrences(of: s, from: windowStart, to: windowEnd) {
                items.append(CashFlowForecastItem(
                    id: "\(s.id.value)-\(Int(date.timeIntervalSince1970))",
                    scheduledId: s.id, date: date, amount: s.transAmount,
                    isInflow: s.transCode == .deposit,
                    payeeName: payeeName, categoryPath: catPath
                ))
            }
        }
        items.sort { $0.date < $1.date }

        var daysMap: [Date: (Double, Double)] = [:]
        for i in 0...days {
            let d = calendar.date(byAdding: .day, value: i, to: windowStart)!
            daysMap[calendar.startOfDay(for: d)] = (0, 0)
        }
        for item in items {
            let key = calendar.startOfDay(for: item.date)
            var v = daysMap[key] ?? (0, 0)
            if item.isInflow { v.0 += item.amount } else { v.1 += item.amount }
            daysMap[key] = v
        }
        let dailyPoints = daysMap.keys.sorted().map { key -> CashFlowForecastDay in
            let v = daysMap[key]!
            return CashFlowForecastDay(date: key, inflow: v.0, outflow: v.1)
        }

        self.forecastSummary = CashFlowForecastSummary(
            windowStart: windowStart, windowEnd: windowEnd,
            days: dailyPoints, items: items,
            totalInflow: dailyPoints.reduce(0.0) { $0 + $1.inflow },
            totalOutflow: dailyPoints.reduce(0.0) { $0 + $1.outflow },
            startingBalance: startingBalance
        )
        self.forecastIsLoading = false
    }

    /// 在 [start, end] 内展开 scheduled 的发生日
    /// `repeatNum` 语义为"剩余次数"（见 `markAsPaid` 的递减），`.times` 需逐次递减
    private static func forecastOccurrences(
        of scheduled: ScheduledData, from start: Date, to end: Date
    ) -> [Date] {
        var result: [Date] = []
        guard let dueDate = scheduled.dueDate.optDate else { return result }

        guard var typeNum = scheduled.repeatTypeNum else {
            if dueDate >= start && dueDate <= end { result.append(dueDate) }
            return result
        }

        var current = dueDate
        var iterations = 0
        let maxIterations = 1000

        while iterations < maxIterations {
            iterations += 1
            if current >= start && current <= end { result.append(current) }
            if current > end { break }
            guard let next = typeNum.nextDate(current) else { break }
            current = next
            if case .times(let t, let remaining) = typeNum {
                if let dec = remaining.dec { typeNum = .times(t, dec) } else { break }
            }
        }
        return result
    }
}
