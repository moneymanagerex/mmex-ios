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
    
    func openDatabase(at url: URL) {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                db = try Connection(url.path)
                print("Connected to database: \(url.path)")
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
            setJournalModeDelete(db: db)
        } else {
            isDatabaseConnected = false
            databaseURL = nil
        }
    }

    func setJournalModeDelete(db: Connection) {
        do {
            try db.execute("PRAGMA journal_mode = MEMORY;")
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

    func setTempStoreDirectory(db: Connection) {
        // Get the path to the app's sandbox Caches directory
        let fileManager = FileManager.default
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            let tempStoreSQL = "PRAGMA temp_store_directory = '\(cacheDir)';"
            
            do {
                try db.execute(tempStoreSQL)
                print("Temporary store directory set to \(cacheDir)")
            } catch {
                print("Failed to set temp store directory: \(error)")
            }
        }
    }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Nullify the connection and reset the state
        isDatabaseConnected = false
        db = nil
        databaseURL = nil
        print("Database connection closed.")
    }

    func getSchemaVersion() -> Int32? { Repository(db)?.userVersion }

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
