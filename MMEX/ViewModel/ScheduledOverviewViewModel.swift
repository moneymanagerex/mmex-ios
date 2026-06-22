//
//  ScheduledOverviewViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

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
    
    func load(from vm: ViewModel, accountId: DataId? = nil) {
        isLoading = true
        defer { isLoading = false }
        
        guard let scheduledData = vm.scheduledList.data.readyValue,
              let order = vm.scheduledList.order.readyValue else {
            clearAll()
            return
        }
        
        let today = Date()
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
            
            guard let nextDate = scheduled.nextDueDate() else { continue }
            
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
    
    func skip(_ item: ScheduledOverviewItem, in vm: ViewModel) async -> Bool {
        guard let nextDate = item.scheduled.nextDueDate(from: item.nextDueDate) else {
            return false
        }
        var updated = item.scheduled
        updated.dueDate = DateString(nextDate)
        return updateScheduled(updated, in: vm)
    }
    
    func markAsPaid(_ item: ScheduledOverviewItem, in vm: ViewModel) async -> Bool {
        guard createTransaction(from: item.scheduled, using: item.nextDueDate, in: vm) else {
            return false
        }
        
        guard let nextDate = item.scheduled.nextDueDate(from: item.nextDueDate) else {
            return true
        }
        var updated = item.scheduled
        updated.dueDate = DateString(nextDate)
        return updateScheduled(updated, in: vm)
    }
    
    // MARK: - Helpers
    
    private func updateScheduled(_ data: ScheduledData, in vm: ViewModel) -> Bool {
        guard let repo = ScheduledRepository(vm.db) else { return false }
        return repo.update(data)
    }
    
    private func createTransaction(from scheduled: ScheduledData, using dueDate: Date, in vm: ViewModel) -> Bool {
        var transaction = TransactionData(
            accountId: scheduled.accountId,
            toAccountId: scheduled.toAccountId,
            payeeId: scheduled.payeeId,
            transCode: scheduled.transCode,
            transAmount: scheduled.transAmount,
            status: .reconciled,
            transactionNumber: scheduled.transactionNumber,
            notes: scheduled.notes,
            categId: scheduled.categId,
            transDate: DateTimeString(dueDate),
            followUpId: scheduled.followUpId,
            toTransAmount: scheduled.toTransAmount,
            color: scheduled.color
        )
        
        if let splits = vm.scheduledList.split.readyValue?[scheduled.id] {
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
        
        guard let repo = TransactionRepository(vm.db) else { return false }
        var txn = transaction
        return repo.insert(&txn)
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
