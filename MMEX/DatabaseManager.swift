//
//  DatabaseManager.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/8.
//

import Foundation
import SQLite

class DataManager {
    let db: Connection?
    
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
    
    func getAccountRepository() -> AccountRepository {
        return AccountRepository(db: db)
    }

    func getPayeeRepository() -> PayeeRepository {
        return PayeeRepository(db: db)
    }

    func getCategoryRepository() -> CategoryRepository {
        return CategoryRepository(db: db)
    }

    func getTransactionRepository() -> TransactionRepository {
        return TransactionRepository(db: db)
    }
}
