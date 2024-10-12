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

    private var cancellables = Set<AnyCancellable>()

    //
    private var env: EnvironmentManager
    private var infotableRepo: InfotableRepository?
    private var transactionRepo: TransactionRepository?
    private var accountRepo: AccountRepository?
    private var currencyRepo: CurrencyRepository?

    @Published var currencies: [CurrencyData] = []

    @Published var accounts: [AccountData] = []
    @Published var accountDict: [DataId: AccountData] = [: ] // for lookup
    @Published var accountId: [DataId] = []  // sorted by name

    @Published var categories: [CategoryData] = []
    @Published var categoryDict: [DataId: CategoryData] = [:] // for lookup

    @Published var payees: [PayeeData] = []
    @Published var payeeDict: [DataId: PayeeData] = [:] // for lookup

    @Published var txns: [TransactionData] = []
    @Published var txns_per_day: [String: [TransactionData]] = [:]

    init(env: EnvironmentManager) {
        self.env = env

        self.infotableRepo = self.env.infotableRepository
        self.transactionRepo = self.env.transactionRepository
        self.accountRepo = self.env.accountRepository
        self.currencyRepo = self.env.currencyRepository
        loadInfo()
        setupBindings()
        loadAccounts()
        loadCurrencies()
    }

    // Load default values from Infotable and populate Published variables
    func loadInfo() {
        if let baseCurrencyId = infotableRepo?.getValue(for: InfoKey.baseCurrencyID.id, as: DataId.self) {
            self.baseCurrencyId = baseCurrencyId
            baseCurrency = currencyRepo?.pluck(
                key: InfoKey.baseCurrencyID.id,
                from: CurrencyRepository.table.filter(CurrencyRepository.col_id == Int64(baseCurrencyId))
            ).toOptional()
        }

        if let defaultAccountId = infotableRepo?.getValue(for: InfoKey.defaultAccountID.id, as: DataId.self) {
            self.defaultAccountId = defaultAccountId
            defaultAccount = accountRepo?.pluck(
                key: InfoKey.defaultAccountID.id,
                from: AccountRepository.table.filter(AccountRepository.col_id == Int64(defaultAccountId))
            ).toOptional()
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
        _ = infotableRepo?.setValue(Int64(currencyId), for: InfoKey.baseCurrencyID.id)
    }

    private func saveDefaultAccount(_ accountId: DataId) {
        _ = infotableRepo?.setValue(Int64(accountId), for: InfoKey.defaultAccountID.id)
    }

    func loadAccounts() {
        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = self.accountRepo?.load() ?? []
            let loadedAccountDict = Dictionary(uniqueKeysWithValues: loadedAccounts.map { ($0.id, $0) })
            typealias A = AccountRepository
            let id = self.accountRepo?.loadId(from: A.table.order(A.col_name)) ?? []
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

    func loadCategories() {
        let repository = env.categoryRepository
        DispatchQueue.global(qos: .background).async {
            let loadedCategories = repository?.load() ?? []
            let loadedCategoryDict = Dictionary(uniqueKeysWithValues: loadedCategories.map { ($0.id, $0) })
            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.categoryDict = loadedCategoryDict
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
        let repository = env.payeeRepository

        DispatchQueue.global(qos: .background).async {
            let loadedPayees = repository?.load() ?? []
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
        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = self.currencyRepo?.load() ?? []
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies

                if (loadedCurrencies.count == 1) {
                    self.baseCurrencyId = loadedCurrencies.first!.id
                }
            }
        }
    }

    func loadTransactions(for accountId: DataId? = nil, startDate: Date? = nil, endDate: Date? = nil) {
        DispatchQueue.global(qos: .background).async {
            var loadedTransactions = self.transactionRepo?.loadRecent(accountId: accountId, startDate: startDate, endDate: endDate) ?? []
            for i in loadedTransactions.indices {
                // TODO other better indicator
                if loadedTransactions[i].categId <= 0 {
                    loadedTransactions[i].splits = self.env.transactionSplitRepository?.load(for: loadedTransactions[i]) ?? []
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

        guard let repository = env.transactionRepository else { return }

        if repository.insertWithSplits(&txn) {
            self.txns.append(txn) // id is ready after repo call
        } else {
            // TODO
        }
    }
    func updateTransaction(_ data: inout TransactionData) -> Bool {
        guard let repository = env.transactionRepository else { return false } 
        return repository.updateWithSplits(&data)
    }
    func deleteTransaction(_ data: TransactionData) -> Bool {
        guard let repository = env.transactionRepository else { return false }
        guard let repositorySplit = env.transactionSplitRepository else { return false }
        return repository.delete(data) && repositorySplit.delete(data)
    }
}
