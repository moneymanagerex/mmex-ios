//
//  ScheduledOverviewViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI
import SQLite

@MainActor
class ScheduledOverviewViewModel: ObservableObject {
    @Published var overdue: [ScheduledOverviewItem] = []
    @Published var dueToday: [ScheduledOverviewItem] = []
    @Published var dueSoon: [ScheduledOverviewItem] = []
    @Published var upcoming: [ScheduledOverviewItem] = []
    @Published var isLoading = false
    
    private let calendar = Calendar.current
    private let maxOverdueDays = 30
    private let maxUpcomingDays = 30
    
    // MARK: - Loading
    
    func load(
        scheduledData: [DataId: ScheduledData]?,
        order: [DataId]?,
        isLoading: Bool,
        accountId: DataId? = nil
    ) {
        self.isLoading = isLoading

        guard let scheduledData, let order else {
            clearAll()
            return
        }
        
        let today = calendar.startOfDay(for: Date())
        var overdueItems: [ScheduledOverviewItem] = []
        var dueTodayItems: [ScheduledOverviewItem] = []
        var dueSoonItems: [ScheduledOverviewItem] = []
        var upcomingItems: [ScheduledOverviewItem] = []
        
        for id in order {
            guard let scheduled = scheduledData[id],
                  scheduled.status != .void else { continue }
            if let accountId = accountId, !accountId.isVoid {
                guard scheduled.accountId == accountId || scheduled.toAccountId == accountId else {
                    continue
                }
            }
            
            guard let nextDateRaw = scheduled.nextDueDate() else { continue }
            let nextDate = calendar.startOfDay(for: nextDateRaw)
            
            let daysUntil = calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
            if daysUntil < -maxOverdueDays || daysUntil > maxUpcomingDays {
                continue
            }
            
            let item = ScheduledOverviewItem(
                id: id,
                scheduled: scheduled,
                nextDueDate: nextDate,
                daysUntil: daysUntil
            )
            
            switch item.status {
            case .overdue: overdueItems.append(item)
            case .dueToday: dueTodayItems.append(item)
            case .dueSoon: dueSoonItems.append(item)
            case .upcoming: upcomingItems.append(item)
            }
        }
        
        self.overdue = overdueItems.sorted { $0.nextDueDate < $1.nextDueDate }
        self.dueToday = dueTodayItems.sorted { $0.scheduled.transAmount > $1.scheduled.transAmount }
        self.dueSoon = dueSoonItems.sorted { $0.nextDueDate < $1.nextDueDate }
        self.upcoming = upcomingItems.sorted { $0.nextDueDate < $1.nextDueDate }
    }
    
    private func clearAll() {
        overdue = []
        dueToday = []
        dueSoon = []
        upcoming = []
    }
    
    // MARK: - Actions
    
    func skip(_ item: ScheduledOverviewItem, db: SQLite.Connection?) async -> Bool {
        guard let nextDate = item.scheduled.nextDueDate(from: item.nextDueDate) else {
            return false
        }
        var updated = item.scheduled
        updated.dueDate = DateString(nextDate)
        return updateScheduled(updated, db: db)
    }

    func markAsPaid(_ item: ScheduledOverviewItem, splits: [DataId: [ScheduledSplitData]], db: SQLite.Connection?) async -> Bool {
        guard createTransaction(from: item.scheduled, using: item.nextDueDate, splits: splits[item.id] ?? [], db: db) else {
            return false
        }
        
        guard let nextDate = item.scheduled.nextDueDate(from: item.nextDueDate) else {
            var completed = item.scheduled
            completed.status = .void
            completed.repeatAuto = .none
            completed.repeatType = .once
            completed.repeatNum = 0

            return updateScheduled(completed, db: db)
        }
        var updated = item.scheduled
        updated.dueDate = DateString(nextDate)

        if let typeNum = item.scheduled.repeatTypeNum {
            switch typeNum {
            case .times(let type, let remaining):
                if remaining.value > 1 {
                    updated.repeatNum = remaining.value - 1
                    updated.repeatType = type
                } else {
                    updated.status = .void
                    updated.repeatAuto = .none
                    updated.repeatType = .once
                    updated.repeatNum = 0
                }
            default:
                break
            }
        }

        return updateScheduled(updated, db: db)
    }
    
    // MARK: - Helpers
    
    private func updateScheduled(_ data: ScheduledData, db: SQLite.Connection?) -> Bool {
        guard let repo = ScheduledRepository(db) else { return false }
        return repo.update(data)
    }

    private func createTransaction(from scheduled: ScheduledData, using dueDate: Date, splits: [ScheduledSplitData], db: SQLite.Connection?) -> Bool {
        var transaction = TransactionData(
            accountId: scheduled.accountId,
            toAccountId: scheduled.toAccountId,
            payeeId: scheduled.payeeId,
            transCode: scheduled.transCode,
            transAmount: scheduled.transAmount,
            status: scheduled.status,
            transactionNumber: scheduled.transactionNumber,
            notes: scheduled.notes,
            categId: scheduled.categId,
            transDate: DateTimeString(dueDate),
            followUpId: scheduled.followUpId,
            toTransAmount: scheduled.toTransAmount,
            color: scheduled.color
        )
        
        if !splits.isEmpty {
            transaction.splits = splits.map { split in
                TransactionSplitData(
                    id: .void,
                    transId: .void,
                    categId: split.categId,
                    amount: split.amount,
                    notes: split.notes
                )
            }
        }
        
        guard let repo = TransactionRepository(db) else { return false }
        var txn = transaction
        return repo.insertWithSplits(&txn)
    }
}

// MARK: - ScheduledOverviewItem

struct ScheduledOverviewItem: Identifiable {
    let id: DataId
    let scheduled: ScheduledData
    let nextDueDate: Date
    let daysUntil: Int
    
    var isRecurring: Bool { scheduled.isRecurring }
    
    enum Status {
        case overdue, dueToday, dueSoon, upcoming
    }
    
    var status: Status {
        if daysUntil < 0 { return .overdue }
        if daysUntil == 0 { return .dueToday }
        if daysUntil <= 7 { return .dueSoon }
        return .upcoming
    }
    
    var daysText: String {
        if daysUntil < 0 {
            return "\(abs(daysUntil)) day\(abs(daysUntil) > 1 ? "s" : "") overdue"
        } else if daysUntil == 0 {
            return "Due today"
        } else {
            return "In \(daysUntil) day\(daysUntil > 1 ? "s" : "")"
        }
    }
}
