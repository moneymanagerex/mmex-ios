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
        // TODO
    }

    init(databaseURL: URL) {
        if databaseURL.startAccessingSecurityScopedResource() {
            defer { databaseURL.stopAccessingSecurityScopedResource() }
            
            do {
                db = try Connection(databaseURL.path)
                print("Connected to database: \(databaseURL.path)")
                setJournalModeDelete(connection: db!)
            } catch {
                print("Failed to connect to database: \(error)")
                db = nil
            }
        } else {
            db = nil
            print("Failed to access security-scoped resource")
        }
    }
    
    func openDabase(at databaseURL: URL) {
        self.databaseURL = databaseURL
        if databaseURL.startAccessingSecurityScopedResource() {
            defer { databaseURL.stopAccessingSecurityScopedResource() }
            do {
                db = try Connection(databaseURL.path)
                print("Connected to database: \(databaseURL.path)")
                setJournalModeDelete(connection: db!)
            } catch {
                print("Failed to connect to database: \(error)")
                db = nil
            }
        } else {
            db = nil
            print("Failed to access security-scoped resource")
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

    func getRepository()                 -> Repository { Repository(db: db) }
    func getInfotableRepository()        -> InfotableRepository { InfotableRepository(db: db) }
    func getCurrencyRepository()         -> CurrencyRepository { CurrencyRepository(db: db) }
    func getCurrencyHistoryRepository()  -> CurrencyRepository { CurrencyRepository(db: db) }
    func getAccountRepository()          -> AccountRepository { AccountRepository(db: db) }
    func getAssetRepository()            -> AssetRepository { AssetRepository(db: db) }
    func getStockRepository()            -> StockRepository { StockRepository(db: db) }
    func getStockHistoryRepository()     -> StockRepository { StockRepository(db: db) }
    func getCategoryRepository()         -> CategoryRepository { CategoryRepository(db: db) }
    func getPayeeRepository()            -> PayeeRepository { PayeeRepository(db: db) }
    func getTransactionRepository()      -> TransactionRepository { TransactionRepository(db: db) }
    func getTransactionSplitRepository() -> TransactionSplitRepository { TransactionSplitRepository(db: db) }
    func getTransactionLinkRepository()  -> TransactionLinkRepository { TransactionLinkRepository(db: db) }
    func getTransactionShareRepository() -> TransactionShareRepository { TransactionShareRepository(db: db) }
    func getScheduledRepository()        -> ScheduledRepository { ScheduledRepository(db: db) }
    func getScheduledSplitRepository()   -> ScheduledSplitRepository { ScheduledSplitRepository(db: db) }
    func getTagRepository()              -> TagRepository { TagRepository(db: db) }
    func getTagLinkRepository()          -> TagLinkRepository { TagLinkRepository(db: db) }
    func getAttachmentRepository()       -> AttachmentRepository { AttachmentRepository(db: db) }
    func getBudgetYearRepository()       -> BudgetYearRepository { BudgetYearRepository(db: db) }
    func getBudgetTableRepository()      -> BudgetTableRepository { BudgetTableRepository(db: db) }
    func getReportRepository()           -> ReportRepository { ReportRepository(db: db) }
}
