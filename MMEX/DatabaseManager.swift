//
//  DatabaseManager.swift
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

    init() {
        connectToStoredDatabase()
    }
    
    func openDatabase(at databaseURL: URL) {
        self.databaseURL = databaseURL
        if databaseURL.startAccessingSecurityScopedResource() {
            defer { databaseURL.stopAccessingSecurityScopedResource() }
            do {
                db = try Connection(databaseURL.path)
                print("Connected to database: \(databaseURL.path)")
                setJournalModeDelete(connection: db!)
                isDatabaseConnected = true
            } catch {
                print("Failed to connect to database: \(error)")
                db = nil
                isDatabaseConnected = false
            }
        } else {
            db = nil
            isDatabaseConnected = false
            print("Failed to access security-scoped resource: \(databaseURL.path)")
        }
    }

    func setJournalModeDelete(connection: Connection) {
        do {
            try connection.execute("PRAGMA journal_mode = MEMORY;")
            print("Journal mode set to MEMORY")
        } catch {
            print("Failed to set journal mode: \(error)")
        }
    }
    
    /// Method to connect to a previously stored database path if available
    private func connectToStoredDatabase() {
        if let storedPath = UserDefaults.standard.string(forKey: "SelectedFilePath") {
            let storedURL = URL(fileURLWithPath: storedPath)
            openDatabase(at: storedURL)
        } else {
            print("No stored database path found.")
        }
    }
    
    func setTempStoreDirectory(connection: Connection) {
        // Get the path to the app's sandbox Caches directory
        let fileManager = FileManager.default
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            let tempStoreSQL = "PRAGMA temp_store_directory = '\(cacheDir)';"
            
            do {
                try connection.execute(tempStoreSQL)
                print("Temporary store directory set to \(cacheDir)")
            } catch {
                print("Failed to set temp store directory: \(error)")
            }
        }
    }
    
    func getSchemaVersion() -> Int32? {
        if let db {
            return db.userVersion
        }
        return nil
    }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Nullify the connection and reset the state
        db = nil
        isDatabaseConnected = false
        databaseURL = nil
        print("Database connection closed.")
    }

    var repository                 : Repository                 { Repository(db: db) }
    var infotableRepository        : InfotableRepository        { InfotableRepository(db: db) }
    var currencyRepository         : CurrencyRepository         { CurrencyRepository(db: db) }
    var currencyHistoryRepository  : CurrencyRepository         { CurrencyRepository(db: db) }
    var accountRepository          : AccountRepository          { AccountRepository(db: db) }
    var assetRepository            : AssetRepository            { AssetRepository(db: db) }
    var stockRepository            : StockRepository            { StockRepository(db: db) }
    var stockHistoryRepository     : StockRepository            { StockRepository(db: db) }
    var categoryRepository         : CategoryRepository         { CategoryRepository(db: db) }
    var payeeRepository            : PayeeRepository            { PayeeRepository(db: db) }
    var transactionRepository      : TransactionRepository      { TransactionRepository(db: db) }
    var transactionSplitRepository : TransactionSplitRepository { TransactionSplitRepository(db: db) }
    var transactionLinkRepository  : TransactionLinkRepository  { TransactionLinkRepository(db: db) }
    var transactionShareRepository : TransactionShareRepository { TransactionShareRepository(db: db) }
    var scheduledRepository        : ScheduledRepository        { ScheduledRepository(db: db) }
    var scheduledSplitRepository   : ScheduledSplitRepository   { ScheduledSplitRepository(db: db) }
    var tagRepository              : TagRepository              { TagRepository(db: db) }
    var tagLinkRepository          : TagLinkRepository          { TagLinkRepository(db: db) }
    var fieldRepository            : FieldRepository            { FieldRepository(db: db) }
    var fieldContentRepository     : FieldContentRepository     { FieldContentRepository(db: db) }
    var attachmentRepository       : AttachmentRepository       { AttachmentRepository(db: db) }
    var budgetYearRepository       : BudgetYearRepository       { BudgetYearRepository(db: db) }
    var budgetTableRepository      : BudgetTableRepository      { BudgetTableRepository(db: db) }
    var reportRepository           : ReportRepository           { ReportRepository(db: db) }
}
