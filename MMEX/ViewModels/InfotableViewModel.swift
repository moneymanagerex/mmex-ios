//
//  InfotableViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/24.
//

import Foundation
import SQLite
import Combine

class InfotableViewModel: ObservableObject {
    // for the view to observe
    @Published var baseCurrencyId: Int64 = 0
    @Published var defaultAccountId: Int64 = 0
    @Published var baseCurrency: CurrencyData?
    @Published var defaultAccount: AccountData?

    private var cancellables = Set<AnyCancellable>()

    //
    private var dataManager: DataManager
    private var infotableRepo: InfotableRepository
    private var transactionRepo: TransactionRepository
    private var accountRepo: AccountRepository
    private var currencyRepo: CurrencyRepository

    @Published var currencies: [CurrencyData] = []
    @Published var accounts: [AccountWithCurrency] = []

    @Published var txns: [TransactionData] = []
    @Published var txns_per_day: [String: [TransactionData]] = [:]

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        self.infotableRepo = self.dataManager.getInfotableRepository()
        self.transactionRepo = self.dataManager.getTransactionRepository()
        self.accountRepo = self.dataManager.getAccountRepository()
        self.currencyRepo = self.dataManager.getCurrencyRepository()
        loadInfo()
        setupBindings()
        loadAccounts()
        loadCurrencies()
    }

    // Load default values from Infotable and populate Published variables
    func loadInfo() {
        if let baseCurrencyId = infotableRepo.getValue(for: InfoKey.baseCurrencyID.id, as: Int64.self) {
            self.baseCurrencyId = baseCurrencyId
            baseCurrency = currencyRepo.pluck(
                from: CurrencyRepository.table.filter(CurrencyRepository.col_id == baseCurrencyId),
                key: InfoKey.baseCurrencyID.id
            )
        }

        if let defaultAccountId = infotableRepo.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
            self.defaultAccountId = defaultAccountId
            defaultAccount = accountRepo.pluck(
                from: AccountRepository.table.filter(AccountRepository.col_id == defaultAccountId),
                key: InfoKey.defaultAccountID.id
            )
        }
    }
    
    func getSchemaVersion() -> Int32 {
        return self.dataManager.getSchemaVersion() ?? 0
    }
    
    func getDatabaseURL() -> URL {
        return self.dataManager.databaseURL!
    }

    // Set up individual bindings for each @Published property
    private func setupBindings() {
        // Bind for defaultAccountId, using dropFirst to ignore initial assignment
        $defaultAccountId
            .dropFirst() // Ignore the first emitted value
            .sink { [weak self] accountId in
                self?.saveDefaultAccount(accountId)
                self?.loadTransactions()
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
    private func saveBaseCurrency(_ currencyId: Int64) {
        infotableRepo.setValue(currencyId, for: InfoKey.baseCurrencyID.id)
    }

    private func saveDefaultAccount(_ accountId: Int64) {
        infotableRepo.setValue(accountId, for: InfoKey.defaultAccountID.id)
    }

    func loadAccounts() {
        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = self.accountRepo.loadWithCurrency()
            DispatchQueue.main.async {
                self.accounts = loadedAccounts

                if (loadedAccounts.count == 1) {
                    self.defaultAccountId = loadedAccounts.first!.data.id
                }
            }
        }
    }

    func loadCurrencies() {
        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = self.currencyRepo.load()
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies

                if (loadedCurrencies.count == 1) {
                    self.baseCurrencyId = loadedCurrencies.first!.id
                }
            }
        }
    }

    func loadTransactions() {
        DispatchQueue.global(qos: .background).async {
            let loadTransactions = self.transactionRepo.loadRecent(accountId: self.defaultAccountId)

            DispatchQueue.main.async {
                self.txns = loadTransactions.filter { txn in txn.deletedTime.isEmpty }
                self.txns_per_day = Dictionary(grouping: self.txns) { txn in
                    // Extract the date portion (ignoring the time) from ISO-8601 string
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format

                    if let date = formatter.date(from: txn.transDate) {
                        formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
                        return formatter.string(from: date)
                    }
                    return txn.transDate // If parsing fails, return original string
                }
            }
        }
    }
}
