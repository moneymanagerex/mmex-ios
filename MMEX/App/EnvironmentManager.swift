//
//  EnvironmentManager.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/8.
//

import Foundation
import SQLite

class EnvironmentManager: ObservableObject {
    // for file database: db != nil && databaseURL != nil
    // for in-memmory database: db != nil && databaseURL == nil
    @Published var isDatabaseConnected = false
    private(set) var db: Connection?
    private(set) var databaseURL: URL?

    // cache
    var currencyCache = CurrencyCache()
    var accountCache  = AccountCache()

    var theme = Theme()

    init(withStoredDatabase: Void) {
        connectToStoredDatabase()
    }

    init(withSampleDatabaseInMemory: Void) {
        createDatabase(at: nil, sampleData: true)
    }

    init() {
    }
}

extension EnvironmentManager {
    func openDatabase(at url: URL?, isNew: Bool = false) {
        db = nil
        if let url {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    db = try Connection(url.path)
                    log.info("Successfully connected to database: \(url.path)")
                } catch {
                    log.error("Failed to connect to database: \(error)")
                }
            } else {
                log.error("Failed to access security-scoped resource: \(url.path)")
            }
        } else if isNew {
            do {
                db = try Connection()
                log.info("Successfully created database in memory")
            } catch {
                log.error("Failed to create database in memory: \(error)")
            }
        }

        if let db {
            isDatabaseConnected = true
            databaseURL = url
            _ = Repository(db).setPragma(name: "journal_mode", value: "MEMORY")
            if !isNew {
                loadCache()
            }
        } else {
            isDatabaseConnected = false
            databaseURL = nil
        }
    }

    /// Method to connect to a previously stored database path if available
    private func connectToStoredDatabase() {
        guard let storedPath = UserDefaults.standard.string(forKey: "SelectedFilePath") else {
            log.warning("No stored database path found.")
            return
        }
        let storedURL = URL(fileURLWithPath: storedPath)
        openDatabase(at: storedURL)
    }

    func createDatabase(at url: URL?, sampleData: Bool) {
        openDatabase(at: url, isNew: true)
        guard let db else { return }

        guard let tables = Bundle.main.url(forResource: "tables.sql", withExtension: "") else {
            log.error("Cannot find tables.sql")
            closeDatabase()
            return
        }

        if tables.startAccessingSecurityScopedResource() {
            defer { tables.stopAccessingSecurityScopedResource() }
            let repository = Repository(db)
            repository.setUserVersion (19)
            guard repository.execute(url: tables) else {
                closeDatabase()
                return
            }
        } else {
            log.error("Failed to access security-scoped resource: \(tables.path)")
            closeDatabase()
            return
        }

        if sampleData {
            let repository = Repository(db)
            guard repository.insertSampleData() else {
                log.error("Failed to create sample database")
                closeDatabase()
                return
            }
        }

        loadCache()
    }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Nullify the connection and reset the state
        unloadCache()
        isDatabaseConnected = false
        db = nil
        databaseURL = nil
        log.info("Database connection closed.")
    }

    /// basic stats
    func getDatabaseFileName() -> String? {
        return self.databaseURL?.lastPathComponent
    }
    func getDatabaseUserVersion() -> Int32? {
        return self.db?.userVersion
    }
}

extension EnvironmentManager {
    func setTempStoreDirectory(db: Connection) {
        // Get the path to the app's sandbox Caches directory
        let fileManager = FileManager.default
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            _ = Repository(db).setPragma(name: "temp_store_directory", value: "'\(cacheDir)'")
        }
    }
}

extension EnvironmentManager {
    func loadCache() {
        loadCurrency()
        loadAccount()
    }

    func unloadCache() {
        currencyCache.unload()
        accountCache.unload()
    }

    func loadCurrency() {
        let repository = CurrencyRepository(db)
        //print("loading currencyCache")
        DispatchQueue.global(qos: .background).async {
            let data: [Int64: CurrencyData] = repository?.dictUsed() ?? [:]
            DispatchQueue.main.async {
                self.currencyCache.load(data)
                //print("loaded currencyCache")
            }
        }
    }

    func loadAccount() {
        let repository = AccountRepository(db)
        DispatchQueue.global(qos: .background).async {
            let data: [Int64: AccountData] = repository?.dict() ?? [:]
            DispatchQueue.main.async {
                self.accountCache.load(data)
            }
        }
    }
}

extension EnvironmentManager {
    var repository                 : Repository?                 { Repository(db) }
    var infotableRepository        : InfotableRepository?        { InfotableRepository(db) }
    var currencyRepository         : CurrencyRepository?         { CurrencyRepository(db) }
    var currencyHistoryRepository  : CurrencyRepository?         { CurrencyRepository(db) }
    var accountRepository          : AccountRepository?          { AccountRepository(db) }
    var assetRepository            : AssetRepository?            { AssetRepository(db) }
    var stockRepository            : StockRepository?            { StockRepository(db) }
    var stockHistoryRepository     : StockRepository?            { StockRepository(db) }
    var categoryRepository         : CategoryRepository?         { CategoryRepository(db) }
    var payeeRepository            : PayeeRepository?            { PayeeRepository(db) }
    var transactionRepository      : TransactionRepository?      { TransactionRepository(db) }
    var transactionSplitRepository : TransactionSplitRepository? { TransactionSplitRepository(db) }
    var transactionLinkRepository  : TransactionLinkRepository?  { TransactionLinkRepository(db) }
    var transactionShareRepository : TransactionShareRepository? { TransactionShareRepository(db) }
    var scheduledRepository        : ScheduledRepository?        { ScheduledRepository(db) }
    var scheduledSplitRepository   : ScheduledSplitRepository?   { ScheduledSplitRepository(db) }
    var tagRepository              : TagRepository?              { TagRepository(db) }
    var tagLinkRepository          : TagLinkRepository?          { TagLinkRepository(db) }
    var fieldRepository            : FieldRepository?            { FieldRepository(db) }
    var fieldContentRepository     : FieldContentRepository?     { FieldContentRepository(db) }
    var attachmentRepository       : AttachmentRepository?       { AttachmentRepository(db) }
    var budgetYearRepository       : BudgetYearRepository?       { BudgetYearRepository(db) }
    var budgetTableRepository      : BudgetTableRepository?      { BudgetTableRepository(db) }
    var reportRepository           : ReportRepository?           { ReportRepository(db) }
}

extension EnvironmentManager {
    static var sampleData: EnvironmentManager {
        EnvironmentManager(withSampleDatabaseInMemory: ())
    }
}
