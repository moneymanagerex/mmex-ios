//
//  TransactionServiceProtocol.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/17.
//


import Foundation
import Combine

// MARK: - Protocol
protocol TransactionServiceProtocol {
    func fetchTransactions(ids: [DataId]?) async throws -> [TransactionData]
    func fetchTransactions(accountId: DataId?, startDate: Date?, endDate: Date?) async throws -> [TransactionData]
    func fetchTransactions(categoryId: DataId?, startDate: Date?, endDate: Date?) async throws -> [TransactionData]
    func saveTransaction(_ transaction: inout TransactionData) async throws
    func deleteTransaction(_ id: DataId) async throws
    // 通知数据变更（用于聚合服务刷新缓存）
    var didChange: PassthroughSubject<Void, Never> { get }
}

// MARK: - Implementation
actor TransactionService: TransactionServiceProtocol {
    private let repository: TransactionRepository
    private let splitRepository: TransactionSplitRepository
    private var cache: [DataId: TransactionData] = [:]
    
    // 发布变更事件
    nonisolated let didChange = PassthroughSubject<Void, Never>()
    
    init(db: Connection) {
        self.repository = TransactionRepository(db)
        self.splitRepository = TransactionSplitRepository(db)
    }
    
    // 辅助方法：将同步 Repository 调用转为异步
    private func perform<T>(_ operation: @escaping () -> T?) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let result = operation() else {
                    continuation.resume(throwing: ServiceError.repositoryFailed(reason: "Operation returned nil"))
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - Fetch
    func fetchTransactions(ids: [DataId]? = nil) async throws -> [TransactionData] {
        // 如果 ids 非空，尝试从缓存读取
        if let ids = ids, !ids.isEmpty {
            var results: [TransactionData] = []
            var missingIds: [DataId] = []
            for id in ids {
                if let cached = cache[id] {
                    results.append(cached)
                } else {
                    missingIds.append(id)
                }
            }
            if !missingIds.isEmpty {
                // 从数据库加载缺失的
                let loaded = try await perform { self.repository.pluck(id: missingIds[0]).toOptional() } // 简易单条加载，实际应批量
                // 更优解：在 Repository 添加 fetch(ids:) 方法，但现有没有，暂时循环
                for id in missingIds {
                    if let data = try? await perform({ self.repository.pluck(id: id).toOptional() }) {
                        cache[id] = data
                        results.append(data)
                    }
                }
            }
            return results
        } else {
            // 获取全部（可考虑缓存全部，但数据量大时需谨慎）
            let all = try await perform { self.repository.load() }
            // 更新缓存
            for txn in all {
                cache[txn.id] = txn
            }
            return all
        }
    }
    
    func fetchTransactions(accountId: DataId?, startDate: Date?, endDate: Date?) async throws -> [TransactionData] {
        // 直接使用 Repository 的 loadRecent
        let result = try await perform {
            self.repository.loadRecent(accountId: accountId, startDate: startDate, endDate: endDate)
        }
        // 更新缓存
        for txn in result {
            cache[txn.id] = txn
        }
        return result
    }
    
    func fetchTransactions(categoryId: DataId?, startDate: Date?, endDate: Date?) async throws -> [TransactionData] {
        // 先获取时间段内的交易，再根据 categoryId 过滤（含 splits）
        let all = try await fetchTransactions(accountId: nil, startDate: startDate, endDate: endDate)
        guard let categoryId = categoryId else { return all }
        return all.filter {
            $0.categId == categoryId || $0.splits.contains { $0.categId == categoryId }
        }
    }
    
    // MARK: - Write
    func saveTransaction(_ transaction: inout TransactionData) async throws {
        let success = try await perform { () -> Bool in
            if transaction.id.isVoid {
                return self.repository.insert(&transaction)
            } else {
                return self.repository.update(transaction)
            }
        }
        guard success else {
            throw ServiceError.repositoryFailed(reason: "Save transaction failed")
        }
        // 更新缓存
        cache[transaction.id] = transaction
        // 发布变更通知
        didChange.send(())
    }
    
    func deleteTransaction(_ id: DataId) async throws {
        // 先从缓存或数据库获取数据
        guard let data = cache[id] ?? try? await perform({ self.repository.pluck(id: id).toOptional() }) else {
            throw ServiceError.notFound
        }
        let success = try await perform { self.repository.delete(data) }
        guard success else {
            throw ServiceError.deleteFailed
        }
        cache.removeValue(forKey: id)
        // 发布变更通知
        didChange.send(())
    }
}