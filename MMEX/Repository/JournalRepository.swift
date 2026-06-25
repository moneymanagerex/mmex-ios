//
//  JournalRepository.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/24.
//

import Foundation
import SQLite

///
struct JournalRepository {
    private let db: Connection

    init(db: Connection) {
        self.db = db
    }

    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    // MARK: - Load Journals

    /// 加载满足条件的 Journal 列表（包含 splits）
    /// - Parameters:
    ///   - accountId: 可选账户 ID（同时匹配 accountId 和 toAccountId）
    ///   - startDate: 可选开始日期（基于 transDate，即交易日期或计划到期日）
    ///   - endDate: 可选结束日期
    /// - Returns: 按 transDate 降序排列的 JournalData 数组
    func loadJournals(
        accountId: DataId? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        includeScheduled: Bool = true
    ) -> [JournalData] {
        var journals: [JournalData] = []

        // 1. 加载交易（Transaction）
        var transQuery = TransactionRepository.table
            .filter(TransactionRepository.col_deletedTime == "")
        if let accountId {
            transQuery = transQuery.filter(
                TransactionRepository.col_accountId == Int64(accountId) ||
                TransactionRepository.col_toAccountId == Int64(accountId)
            )
        }
        if let startDate {
            transQuery = transQuery.filter(TransactionRepository.col_transDate >= DateTimeString(startDate).string)
        }
        if let endDate {
            transQuery = transQuery.filter(TransactionRepository.col_transDate < DateTimeString(endDate).string)
        }
        transQuery = transQuery.order(TransactionRepository.col_transDate.desc)

        if let rows = try? db.prepare(TransactionRepository.selectData(from: transQuery)) {
            let splitRepo = TransactionSplitRepository(db)
            for row in rows {
                let txn = TransactionRepository.fetchData(row)
                var journal = JournalData(txn)
                if let splits = splitRepo.load(for: txn) {
                    journal.splits = splits.map {
                        JournalSplitData(id: $0.id, categId: $0.categId, amount: $0.amount, notes: $0.notes)
                    }
                }
                journals.append(journal)
            }
        }

        if includeScheduled {
            // 2. 加载计划交易（Scheduled）
            var schedQuery = ScheduledRepository.table
                .filter(ScheduledRepository.col_status != "V")  // 排除已作废
            if let accountId {
                schedQuery = schedQuery.filter(
                    ScheduledRepository.col_accountId == Int64(accountId) ||
                    ScheduledRepository.col_toAccountId == Int64(accountId)
                )
            }
            // 使用下次到期日（dueDate）作为排序和过滤的日期
            if let startDate {
                schedQuery = schedQuery.filter(ScheduledRepository.col_nextOccurrenceDate >= DateString(startDate).string)
            }
            if let endDate {
                schedQuery = schedQuery.filter(ScheduledRepository.col_nextOccurrenceDate < DateString(endDate).string)
            }
            schedQuery = schedQuery.order(ScheduledRepository.col_nextOccurrenceDate.desc)
            
            if let rows = try? db.prepare(ScheduledRepository.selectData(from: schedQuery)) {
                let splitRepo = ScheduledSplitRepository(db)
                for row in rows {
                    let sched = ScheduledRepository.fetchData(row)
                    var journal = JournalData(sched)
                    // 将 dueDate 作为统一的 transDate（用于显示和排序）
                    journal.transDate = DateTimeString(sched.dueDate.string)
                    if let splits = splitRepo.load(for: sched) {
                        journal.splits = splits.map {
                            JournalSplitData(id: $0.id, categId: $0.categId, amount: $0.amount, notes: $0.notes)
                        }
                    }
                    journals.append(journal)
                }
            }
        }

        // 合并并按 transDate 降序排序
        journals.sort { $0.transDate.string > $1.transDate.string }
        return journals
    }

    // MARK: - Save Journal

    /// 保存 Journal（插入或更新），内部处理 splits 的级联保存
    /// - Parameter journal: 待保存的 JournalData（inout 以便更新生成的 ID）
    /// - Returns: 是否成功
    @discardableResult
    func saveJournal(_ journal: inout JournalData) -> Bool {
        switch journal.type {
        case .transaction, .future:
            guard var txn = journal.toTransaction else { return false }
            let repo = TransactionRepository(db)
            if txn.id.isVoid {
                guard repo.insertWithSplits(&txn) else { return false }
            } else {
                guard repo.updateWithSplits(&txn) else { return false }
            }
            journal.transactionId = txn.id
            // 如果类型为 future，可根据需要更新 scheduledId 等，此处暂不处理
            return true

        case .scheduled:
            guard var sched = journal.toScheduled else { return false }
            let repo = ScheduledRepository(db)
            if sched.id.isVoid {
                guard repo.insertWithSplits(&sched) else { return false }
            } else {
                guard repo.updateWithSplits(&sched) else { return false }
            }
            journal.scheduledId = sched.id
            return true
        }
    }

    // MARK: - Delete Journal

    /// 删除 Journal，同时级联删除其 splits
    /// - Parameter journal: 要删除的 JournalData
    /// - Returns: 是否成功
    func deleteJournal(_ journal: JournalData) -> Bool {
        switch journal.type {
        case .transaction, .future:
            guard let txn = journal.toTransaction else { return false }
            let transRepo = TransactionRepository(db)
            let splitRepo = TransactionSplitRepository(db)
            return transRepo.delete(txn) && splitRepo.delete(txn)

        case .scheduled:
            guard let sched = journal.toScheduled else { return false }
            let schedRepo = ScheduledRepository(db)
            let splitRepo = ScheduledSplitRepository(db)
            return schedRepo.delete(sched) && splitRepo.delete(sched)
        }
    }

    // MARK: - Load Splits (独立加载)

    /// 单独加载某个 Journal 的 splits（通常用于按需加载）
    func loadSplits(for journal: JournalData) -> [JournalSplitData] {
        switch journal.type {
        case .transaction, .future:
            guard let txn = journal.toTransaction else { return [] }
            let splits = TransactionSplitRepository(db).load(for: txn) ?? []
            return splits.map {
                JournalSplitData(id: $0.id, categId: $0.categId, amount: $0.amount, notes: $0.notes)
            }

        case .scheduled:
            guard let sched = journal.toScheduled else { return [] }
            let splits = ScheduledSplitRepository(db).load(for: sched) ?? []
            return splits.map {
                JournalSplitData(id: $0.id, categId: $0.categId, amount: $0.amount, notes: $0.notes)
            }
        }
    }
}
