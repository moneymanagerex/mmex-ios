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
    let databaseURL: URL

    // for the view to observe
    @Published var baseCurrencyId: Int64 = 0
    @Published var defaultAccountId: Int64 = 0
    @Published var baseCurrency: CurrencyData?
    @Published var defaultAccount: AccountData?

    private var cancellables = Set<AnyCancellable>()

    //
    private var dataManager: DataManager
    private var infotableRepo: InfotableRepository
    private var accountRepo: AccountRepository
    private var currencyRepo: CurrencyRepository

    @Published var currencies: [CurrencyData] = []
    @Published var accounts: [AccountFull] = []

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.dataManager = DataManager(databaseURL: databaseURL)

        self.infotableRepo = self.dataManager.getInfotableRepository()
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
            baseCurrency = currencyRepo.pluckData(table: CurrencyRepository.repositoryTable.filter(CurrencyRepository.col_id == baseCurrencyId), key: InfoKey.baseCurrencyID.id)
        }

        if let defaultAccountId = infotableRepo.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
            self.defaultAccountId = defaultAccountId
            defaultAccount = accountRepo.pluckData(table: AccountRepository.repositoryTable.filter(AccountRepository.col_id == defaultAccountId), key: InfoKey.defaultAccountID.id)
        }
    }

    // Set up individual bindings for each @Published property
    private func setupBindings() {
        // Bind for defaultAccountId, using dropFirst to ignore initial assignment
        $defaultAccountId
            .dropFirst() // Ignore the first emitted value
            .sink { [weak self] accountId in
                self?.saveDefaultAccount(accountId)
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
                    self.defaultAccountId = loadedAccounts.first!.id
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
}
