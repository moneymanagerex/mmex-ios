//
//  Database.swift
//  MMEX
//
//  2024-09-08: Created by Lisheng Guan
//

import Foundation
import SQLite

extension ViewModel {
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
        } else {
            isDatabaseConnected = false
            databaseURL = nil
        }
    }

    /// Method to connect to a previously stored database path if available
    func connectToStoredDatabase() {
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

        guard let tables = Bundle.main.url(forResource: "tables", withExtension: "sql") else {
            log.error("Cannot find tables.sql")
            closeDatabase()
            return
        }

        let repository = Repository(db)
        repository.setUserVersion (19)
        guard repository.execute(url: tables) else {
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
    }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Write any unsaved changes back to the original file
        if let databaseURL = databaseURL {
            log.info("Attempting to write back changes to: \(databaseURL.path)")
            // Ensure the file is a security-scoped resource
            if databaseURL.startAccessingSecurityScopedResource() {
                defer { databaseURL.stopAccessingSecurityScopedResource() }

                // Using NSFileCoordinator to handle cloud files correctly
                let fileCoordinator = NSFileCoordinator()
                var error: NSError?

                // Perform coordinated write to ensure cloud compatibility
                fileCoordinator.coordinate(writingItemAt: databaseURL, options: .forReplacing, error: &error) { newURL in
                    // TODO: conflict handle?
                    log.info("to: \(newURL.path)")
                }

                // Handle any errors from the coordination
                if let coordinationError = error {
                    log.error("File coordination error: \(coordinationError)")
                }
            } else {
                log.error("Failed to access security-scoped resource for writing: \(databaseURL.path)")
            }
        }
        // Nullify the connection and reset the state
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

extension ViewModel {
    func setTempStoreDirectory(db: Connection) {
        // Get the path to the app's sandbox Caches directory
        let fileManager = FileManager.default
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            _ = Repository(db).setPragma(name: "temp_store_directory", value: "'\(cacheDir)'")
        }
    }
}

extension ViewModel {
    static var sampleData: ViewModel {
        ViewModel(withSampleDatabaseInMemory: ())
    }
}
