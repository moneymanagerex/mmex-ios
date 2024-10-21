//
//  TransactionViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/24.
//

import Foundation
import SwiftUI
import SQLite
import Combine

class TransactionViewModel: ObservableObject {
    // for the view to observe
    @Published var baseCurrencyId: DataId = 0
    @Published var defaultAccountId: DataId = 0
    @Published var baseCurrency: CurrencyData?
    @Published var defaultAccount: AccountData?
    @Published var categDelimiter: String = ":"

    private var cancellables = Set<AnyCancellable>()

    private var env: EnvironmentManager

    @Published var currencies: [CurrencyData] = []

    @Published var accounts: [AccountData] = []
    @Published var accountDict: [DataId: AccountData] = [: ] // for lookup
    @Published var accountId: [DataId] = []  // sorted by name

    @Published var categories: [CategoryData] = []
    @Published var categoryDict: [DataId: CategoryData] = [:] // for lookup
    @Published var filteredCategories: [CategoryData] = []

    @Published var payees: [PayeeData] = []
    @Published var payeeDict: [DataId: PayeeData] = [:] // for lookup

    @Published var txns: [TransactionData] = []
    @Published var txns_per_day: [String: [TransactionData]] = [:]

    init(env: EnvironmentManager) {
        self.env = env

        loadInfo()
        setupBindings()
        loadAccounts()
        loadCurrencies()
    }

    // Load default values from Infotable and populate Published variables
    func loadInfo() {
        let infotableRepository = InfotableRepository(env)
        if let baseCurrencyId = infotableRepository?.getValue(for: InfoKey.baseCurrencyID.id, as: DataId.self) {
            self.baseCurrencyId = baseCurrencyId
            baseCurrency = CurrencyRepository(env)?.pluck(
                key: InfoKey.baseCurrencyID.id,
                from: CurrencyRepository.table.filter(CurrencyRepository.col_id == Int64(baseCurrencyId))
            ).toOptional()
        }

        if let defaultAccountId = infotableRepository?.getValue(for: InfoKey.defaultAccountID.id, as: DataId.self) {
            self.defaultAccountId = defaultAccountId
            defaultAccount = AccountRepository(env)?.pluck(
                key: InfoKey.defaultAccountID.id,
                from: AccountRepository.table.filter(AccountRepository.col_id == Int64(defaultAccountId))
            ).toOptional()
        }

        if let categDelimiter = infotableRepository?.getValue(for: InfoKey.categDelimiter.id, as: String.self) {
            self.categDelimiter = categDelimiter
        }
    }

    // Set up individual bindings for each @Published property
    private func setupBindings() {
        // Bind for defaultAccountId, using dropFirst to ignore initial assignment
        $defaultAccountId
            .dropFirst() // Ignore the first emitted value
            .sink { [weak self] accountId in
                self?.saveDefaultAccount(accountId)
                self?.loadTransactions(for: accountId)
            }
            .store(in: &cancellables)

        // Bind for defaultPayeeId
        $baseCurrencyId
            .dropFirst() // Ignore the first emitted value
            .sink { [weak self] currencyId in
                self?.saveBaseCurrency(currencyId)
            }
            .store(in: &cancellables)
    }

    // Save data back to Infotable
    private func saveBaseCurrency(_ currencyId: DataId) {
        _ = InfotableRepository(env)?.setValue(Int64(currencyId), for: InfoKey.baseCurrencyID.id)
    }

    private func saveDefaultAccount(_ accountId: DataId) {
        _ = InfotableRepository(env)?.setValue(Int64(accountId), for: InfoKey.defaultAccountID.id)
    }

    func loadAccounts() {
        let accountRepository = AccountRepository(self.env)
        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = accountRepository?.load() ?? []
            let loadedAccountDict = Dictionary(uniqueKeysWithValues: loadedAccounts.map { ($0.id, $0) })
            typealias A = AccountRepository
            let id = accountRepository?.loadId(from: A.table.order(A.col_name)) ?? []
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
                self.accountDict = loadedAccountDict
                self.accountId = id

                if (loadedAccounts.count == 1) {
                    self.defaultAccountId = loadedAccounts.first!.id
                }
            }
        }
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
        while let parentCategory = categoryDict[currentCategory.parentId], parentCategory.id != 0 {
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

    func loadPayees() {
        let payeeRepository = PayeeRepository(env)
        DispatchQueue.global(qos: .background).async {
            let loadedPayees = payeeRepository?.load() ?? []
            let loadedPayeeDict = Dictionary(uniqueKeysWithValues: loadedPayees.map { ($0.id, $0) })
            DispatchQueue.main.async {
                self.payees = loadedPayees
                self.payeeDict = loadedPayeeDict
            }
        }
    }

    // TODO pre-join via SQL?
    func getPayeeName(for payeeID: DataId) -> String {
        // Find the payee with the given ID
        if let payee = self.payeeDict[payeeID] {
            return payee.name
        }

        return "Unknown"
    }

    func loadCurrencies() {
        let currencyRepository = CurrencyRepository(env)
        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = currencyRepository?.load() ?? []
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
                if (loadedCurrencies.count == 1) {
                    self.baseCurrencyId = loadedCurrencies.first!.id
                }
            }
        }
    }

    func loadTransactions(for accountId: DataId? = nil, startDate: Date? = nil, endDate: Date? = nil) {
        let transactionRepository = TransactionRepository(env)
        let transactionSplitRepository = TransactionSplitRepository(env)
        DispatchQueue.global(qos: .background).async {
            var loadedTransactions = transactionRepository?.loadRecent(accountId: accountId, startDate: startDate, endDate: endDate) ?? []
            for i in loadedTransactions.indices {
                // TODO other better indicator
                if loadedTransactions[i].categId <= 0 {
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
