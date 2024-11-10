//
//  TransactionViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/24.
//

import Foundation
import Combine
import SwiftUI
import SQLite

class TransactionViewModel: ObservableObject {
    private var env: EnvironmentManager
    @Published var categories: [CategoryData] = []
    @Published var categoryDict: [DataId: CategoryData] = [:] // for lookup
    @Published var filteredCategories: [CategoryData] = []
    @Published var txns: [TransactionData] = []
    @Published var txns_per_day: [String: [TransactionData]] = [:]

    init(env: EnvironmentManager) {
        self.env = env
    }

    private func populateParentCategories(for categories: [CategoryData]) -> [CategoryData] {
        // Create a dictionary for quick parent lookups
        let categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })

        return categories.map { category in
            var updatedCategory = category
            updatedCategory.parentCategories = self.findParentCategories(for: category, in: categoryDict)
            return updatedCategory
        }
    }

    private func findParentCategories(for category: CategoryData, in categoryDict: [DataId: CategoryData]) -> [CategoryData] {
        // Recursive function to find all parent categories
        var parents: [CategoryData] = []

        var currentCategory = category
        while let parentCategory = categoryDict[currentCategory.parentId], !parentCategory.id.isVoid {
            parents.insert(parentCategory, at: 0) // Insert at the beginning to maintain the correct order
            currentCategory = parentCategory
        }

        return parents
    }

    func loadCategories() {
        let categoryRepository = CategoryRepository(env)
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = categoryRepository?.load() ?? []
            let updatedCategories = self.populateParentCategories(for: loadedCategories)
            let loadedCategoryDict = Dictionary(uniqueKeysWithValues: updatedCategories.map { ($0.id, $0) })
            DispatchQueue.main.async {
                self.categories = updatedCategories
                self.categoryDict = loadedCategoryDict
                self.filteredCategories = updatedCategories
            }
        }
    }

    func addCategory(category: inout CategoryData) {
        guard let repository = CategoryRepository(env) else { return }
        if repository.insert(&category) {
            self.categories.append(category)
        }
    }

    func filterCategories(by query: String) {
        if query.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.name.localizedCaseInsensitiveContains(query) }
            filteredCategories = categories.filter { category in
                category.name.localizedCaseInsensitiveContains(query) ||
                category.parentCategories.contains { parent in
                    parent.name.localizedCaseInsensitiveContains(query)
                }
            }
        }
    }

    func getCategoryName(for categoryID: DataId) -> String {
        // Find the category with the given ID
        if let category = self.categoryDict[categoryID] {
            return category.name
        }
        return "Unknown"
    }

    func loadTransactions(for accountId: DataId? = nil, startDate: Date? = nil, endDate: Date? = nil) {
        let transactionRepository = TransactionRepository(env)
        let transactionSplitRepository = TransactionSplitRepository(env)
        DispatchQueue.global(qos: .background).async {
            var loadedTransactions = transactionRepository?.loadRecent(accountId: accountId, startDate: startDate, endDate: endDate) ?? []
            for i in loadedTransactions.indices {
                // TODO other better indicator
                if loadedTransactions[i].categId.isVoid {
                    loadedTransactions[i].splits = transactionSplitRepository?.load(for: loadedTransactions[i]) ?? []
                }
            }

            DispatchQueue.main.async {
                self.txns = loadedTransactions.filter { txn in txn.deletedTime.string.isEmpty }
                self.txns_per_day = Dictionary(grouping: self.txns) { txn in
                    // Extract the date portion (ignoring the time) from ISO-8601 string
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format

                    if let date = formatter.date(from: txn.transDate.string) {
                        formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
                        return formatter.string(from: date)
                    }
                    return txn.transDate.string // If parsing fails, return original string
                }
            }
        }
    }
    
    func filterTransactions(by query: String) {
        let filteredTxns = query.isEmpty ? txns : txns.filter { txn in
            txn.notes.localizedCaseInsensitiveContains(query) ||
            txn.splits.contains { split in
                split.notes.localizedCaseInsensitiveContains(query)
            }
        }
        // TODO: refine and consolidate
        self.txns_per_day = Dictionary(grouping: filteredTxns) { txn in
            // Extract the date portion (ignoring the time) from ISO-8601 string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format

            if let date = formatter.date(from: txn.transDate.string) {
                formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
                return formatter.string(from: date)
            }
            return txn.transDate.string // If parsing fails, return original string
        }
    }

    func addTransaction(txn: inout TransactionData) {
        if txn.transCode == .transfer {
            txn.payeeId = 0
        } else {
            txn.toAccountId = 0
        }

        guard let transactionRepository = TransactionRepository(env) else { return }

        if transactionRepository.insertWithSplits(&txn) {
            self.txns.append(txn) // id is ready after repo call
        } else {
            // TODO
        }
    }

    func updateTransaction(_ data: inout TransactionData) -> Bool {
        guard let transactionRepository = TransactionRepository(env) else { return false }
        return transactionRepository.updateWithSplits(&data)
    }

    func deleteTransaction(_ data: TransactionData) -> Bool {
        guard let transactionRepository = TransactionRepository(env) else { return false }
        guard let transactionSplitRepository = TransactionSplitRepository(env) else { return false }
        return transactionRepository.delete(data) && transactionSplitRepository.delete(data)
    }
}
