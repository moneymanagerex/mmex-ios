//
//  MMEXDatabase.swift
//  MMEX
//
//  2024-09-08: Created by Lisheng Guan
//

import Foundation
import SQLite

extension ViewModel {
    func openDatabase(at url: URL?, isNew: Bool = false, password: String? = nil) {
        unloadAll()
        db = nil
        if let url {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                let fileCoordinator = NSFileCoordinator()
                var error: NSError?

                fileCoordinator.coordinate(readingItemAt: url, options: .forUploading, error: &error) { fileURL in
                    log.info("Redownloading the latest document: \(url)")
                }

                // Handle any errors from the coordination
                if let coordinationError = error {
                    log.error("Redownload error: \(coordinationError)")
                } else {
                    log.info("Successfully redownloaded: \(url)")
                }

                do {
                    db = try Connection(url.path)
                    if let password, let db {
                        let cipherMethods: [(Connection) -> Void] = [
                            { $0.initSQLCipher() },    // SQLCipher
                            { $0.initAES128CBC() } // Custom AES-128 Cipher
                            // Add more cipher methods here as needed
                        ]

                        var cipherInitialized = false
                        for initCipher in cipherMethods {
                            do {
                                initCipher(db) // Try initializing the cipher
                                try db.key(password)
                                cipherInitialized = true
                                break // Exit loop if successful
                            } catch {
                                log.warning("Failed to initialize cipher with method: \(error)")
                                continue
                            }
                        }

                        if !cipherInitialized {
                            throw NSError(domain: "CipherInitialization", code: 1, userInfo: [NSLocalizedDescriptionKey: "All cipher methods failed"])
                        }
                    }
                    saveBookmark(for: url)
                    log.info("Successfully connected to database: \(url.path)")
                } catch {
                    db = nil
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

    func attachDatabase(at url: URL?, alias: String? = nil) {
        guard let db = db else {
            log.error("No primary database connection available to attach the database.")
            return
        }

        guard let url else {
            log.error("No URL provided for the database to attach.")
            return
        }

        // Derive default alias if none is provided
        let resolvedAlias = alias ?? "attach"

        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                // Attach the external database
                try db.attach(.uri(url.path, parameters: [.mode(.readOnly)]), as: resolvedAlias)
                log.info("Successfully attached database at \(url.path) as \(resolvedAlias)")
            } catch {
                log.error("Failed to attach database: \(error)")
            }
        } else {
            log.error("Failed to access security-scoped resource: \(url.path)")
        }

        let repository = Repository(db)

        guard repository.importData() else {
            log.error("Failed to import data")
            detachDatabase()
            return
        }
        detachDatabase()
    }

    func detachDatabase(alias: String? = nil) {
        guard let db = db else {
            log.error("No primary database connection available to detach the database.")
            return
        }
        // Determine the alias to detach
        let resolvedAlias = alias ?? "attach" // Default alias if none is provided
        do {
            try db.detach(resolvedAlias)
            log.info("Successfully detached database with alias \(resolvedAlias)")
        } catch {
            log.error("Failed to detach database: \(error)")
        }
    }

    /// Method to connect to a previously stored database path if available
    func connectToStoredDatabase() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "DatabaseBookmark") else {
            log.warning("No stored database bookmark found.")
            return
        }
        do {
            var isStale = false
            let storedURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)

            if isStale {
                log.error("Bookmark is stale. \(bookmarkData)")
            }
            if storedURL.pathExtension.lowercased() == "mmb" {
                openDatabase(at: storedURL)
            } else {
                // TODO
            }
        }
        catch let error {
            log.error("Failed to restore bookmark: \(error)")
        }
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
        repository.setUserVersion (20)
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
            log.info("Attempting to merge changes to: \(databaseURL.path)")
            // Ensure the file is a security-scoped resource
            if databaseURL.startAccessingSecurityScopedResource() {
                defer { databaseURL.stopAccessingSecurityScopedResource() }

                // Using NSFileCoordinator to handle cloud files correctly
                let fileCoordinator = NSFileCoordinator()
                var error: NSError?

                // Perform coordinated write to ensure cloud compatibility
                fileCoordinator.coordinate(writingItemAt: databaseURL, options: .forMerging, error: &error) { newURL in
                    // TODO: conflict handle?
                    log.info("Merging to: \(newURL.path)")
                }

                // Handle any errors from the coordination
                if let coordinationError = error {
                    log.error("Merging error: \(coordinationError)")
                } else {
                    log.info("Successfully Merged to: \(databaseURL)")
                }
            } else {
                log.error("Failed to access security-scoped resource for writing: \(databaseURL.path)")
            }
        }
        // Nullify the connection and reset the state
        unloadAll()
        isDatabaseConnected = false
        db = nil
        databaseURL = nil
        log.info("Database connection closed.")
    }

    func getDatabaseFileName() -> String? {
        return self.databaseURL?.lastPathComponent
    }

    func getDatabaseUserVersion() -> Int32? {
        return self.db?.userVersion
    }

    var sqliteVersion: SQLiteVersion? {
        return self.db?.sqliteVersion
    }

    private func saveBookmark(for url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "DatabaseBookmark")
            log.info("Bookmark saved successfully.")
        } catch {
            log.error("Failed to save bookmark: \(error)")
        }
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
