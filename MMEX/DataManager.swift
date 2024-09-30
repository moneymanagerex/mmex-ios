//
//  DataManager.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/8.
//

import Foundation
import SQLite

class DataManager: ObservableObject {
    @Published var isDatabaseConnected = false
    private(set) var db: Connection?
    private(set) var databaseURL: URL?

    var currencyData: [Int64: CurrencyData] = [:]
    var currencyFormatter: [Int64: CurrencyFormatter] = [:]

    init() {
        connectToStoredDatabase()
    }
}

extension DataManager {
    func openDatabase(at url: URL, isNew: Bool = false) {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                db = try Connection(url.path)
                print("Successfully connected to database: \(url.path)")
            } catch {
                db = nil
                print("Failed to connect to database: \(error)")
            }
        } else {
            db = nil
            print("Failed to access security-scoped resource: \(url.path)")
        }
        
        if let db {
            isDatabaseConnected = true
            databaseURL = url
            _ = Repository(db).setPragma(name: "journal_mode", value: "MEMORY")
        } else {
            isDatabaseConnected = false
            databaseURL = nil
        }

        if !isNew {
            loadCurrency()
        }
    }

    /// Method to connect to a previously stored database path if available
    private func connectToStoredDatabase() {
        guard let storedPath = UserDefaults.standard.string(forKey: "SelectedFilePath") else {
            print("No stored database path found.")
            return
        }
        let storedURL = URL(fileURLWithPath: storedPath)
        openDatabase(at: storedURL)
    }

    func createDatabase(at url: URL, sampleData: Bool) {
        openDatabase(at: url, isNew: true)
        guard let db else { return }

        guard let tables = Bundle.main.url(forResource: "tables.sql", withExtension: "") else {
            print("Cannot find tables.sql")
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
            print("Failed to access security-scoped resource: \(tables.path)")
            closeDatabase()
            return
        }

        if sampleData {
            let repository = Repository(db)
            guard repository.insertSampleData() else {
                print("Failed to create sample database")
                closeDatabase()
                return
            }
        }
        loadCurrency()
    }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Nullify the connection and reset the state
        isDatabaseConnected = false
        db = nil
        databaseURL = nil
        closeCurrency()
        print("Database connection closed.")
    }

    /// basic stats
    func getDatabaseFileName() -> String? {
        return self.databaseURL?.lastPathComponent
    }
    func getDatabaseUserVersion() -> Int32? {
        return self.db?.userVersion
    }
}

extension DataManager {
    func setTempStoreDirectory(db: Connection) {
        // Get the path to the app's sandbox Caches directory
        let fileManager = FileManager.default
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            _ = Repository(db).setPragma(name: "temp_store_directory", value: "'\(cacheDir)'")
        }
    }
}

extension DataManager {
    func loadCurrency() {
        let repository = CurrencyRepository(db)
        DispatchQueue.global(qos: .background).async {
            let data = repository?.dictUsed() ?? [:]
            DispatchQueue.main.async {
                self.currencyData = data
                self.currencyFormatter = data.mapValues { currency in
                    currency.formatter
                }
            }
        }

    }

    func updateCurrency(id: Int64, data: CurrencyData) {
        currencyData[id] = data
        currencyFormatter[id] = data.formatter
    }

    func closeCurrency() {
        currencyData = [:]
        currencyFormatter = [:]
    }
}

extension DataManager {
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
