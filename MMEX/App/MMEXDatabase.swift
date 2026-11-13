//
//  MMEXDatabase.swift
//  MMEX
//
//  2024-09-08: Created by Lisheng Guan
//

import Foundation
import SQLite

struct NewDatabaseSetup {
    let currencyId: DataId
    let accountName: String
    let accountType: AccountType
    let initialBalance: Double
}

extension ViewModel {
    func openDatabase(at url: URL?, isNew: Bool = false, password: String? = nil) {
        unloadAll()
        db = nil
        releaseDatabaseAccess()
        if let url {
            let hasScopedAccess = url.startAccessingSecurityScopedResource()
            if hasScopedAccess || isLocalDocument(url) {
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
                    if hasScopedAccess { securityScopedDatabaseURL = url }
                    log.info("Successfully connected to database: \(url.path)")
                } catch {
                    db = nil
                    if hasScopedAccess { url.stopAccessingSecurityScopedResource() }
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
        repository.setUserVersion (21)
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

    func availableSetupCurrencies() throws -> [CurrencyData] {
        guard let tables = Bundle.main.url(forResource: "tables", withExtension: "sql") else {
            throw setupError("Cannot find tables.sql")
        }
        let connection = try Connection()
        guard Repository(connection).execute(url: tables),
              let currencies: [CurrencyData] = CurrencyRepository(connection).select(), !currencies.isEmpty else {
            throw setupError("Cannot load currencies")
        }
        return currencies.sorted { $0.localizedName().localizedStandardCompare($1.localizedName()) == .orderedAscending }
    }

    func createConfiguredDatabase(_ setup: NewDatabaseSetup) throws {
        let documents = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let url = documents.appendingPathComponent("My Finances-\(UUID().uuidString).mmb")
        do {
            let connection = try initializeDatabase(setup, at: url)
            guard saveBookmark(for: url) else { throw setupError("Cannot save database access") }
            unloadAll()
            db = nil
            releaseDatabaseAccess()
            db = connection
            databaseURL = url
            isDatabaseConnected = true
        } catch {
            log.error("Failed to create configured database: \(error)")
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    log.error("Failed to remove incomplete database: \(error)")
                }
            }
            throw error
        }
    }

    func prepareDatabaseForExport(_ setup: NewDatabaseSetup) throws -> URL {
        try prepareDatabaseForExport(filename: "My Finances.mmb") { url in
            _ = try initializeDatabase(setup, at: url)
        }
    }

    func prepareSampleDatabaseForExport() throws -> URL {
        try prepareDatabaseForExport(filename: "Sample.mmb") { url in
            guard let tables = Bundle.main.url(forResource: "tables", withExtension: "sql") else {
                throw setupError("Cannot find tables.sql")
            }
            let connection = try Connection(url.path)
            let repository = Repository(connection)
            repository.setUserVersion(21)
            guard repository.execute(url: tables), repository.insertSampleData(),
                  repository.setPragma(name: "journal_mode", value: "MEMORY") else {
                throw setupError("Cannot initialize database")
            }
        }
    }

    private func prepareDatabaseForExport(filename: String, initialize: (URL) throws -> Void) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("MMEX-setup-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        let url = directory.appendingPathComponent(filename)
        do {
            try initialize(url)
            return url
        } catch {
            do { try FileManager.default.removeItem(at: directory) }
            catch { log.error("Failed to remove temporary database: \(error)") }
            throw error
        }
    }

    func openExportedDatabase(at url: URL) throws {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        guard hasScopedAccess || isLocalDocument(url) else {
            throw setupError("The database was saved, but could not be opened. Open it from Files.")
        }
        do {
            let connection = try Connection(url.path)
            guard AccountRepository(connection).count() != nil, saveBookmark(for: url) else {
                throw setupError("The database was saved, but could not be opened. Open it from Files.")
            }
            unloadAll()
            db = nil
            releaseDatabaseAccess()
            db = connection
            databaseURL = url
            if hasScopedAccess { securityScopedDatabaseURL = url }
            isDatabaseConnected = true
        } catch {
            if hasScopedAccess { url.stopAccessingSecurityScopedResource() }
            throw error
        }
    }

    private func initializeDatabase(_ setup: NewDatabaseSetup, at url: URL) throws -> Connection {
        guard !setup.currencyId.isVoid,
              !setup.accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              setup.initialBalance.isFinite else {
            throw setupError("Invalid account details")
        }
        guard let tables = Bundle.main.url(forResource: "tables", withExtension: "sql") else {
            throw setupError("Cannot find tables.sql")
        }
        let connection = try Connection(url.path)
        let repository = Repository(connection)
        repository.setUserVersion(21)
        guard repository.execute(url: tables) else { throw setupError("Cannot initialize database") }
        let currency: CurrencyData? = CurrencyRepository(connection).pluck(id: setup.currencyId).toOptional()
        guard currency != nil else { throw setupError("Cannot find the selected currency") }
        var account = AccountData(
            name: setup.accountName, type: setup.accountType, status: .open,
            initialDate: DateString(Date()), initialBal: setup.initialBalance,
            favoriteAcct: .boolTrue, currencyId: setup.currencyId
        )
        guard AccountRepository(connection).insert(&account) else {
            throw setupError("Cannot initialize the first account or database settings")
        }
        let settings = [
            InfotableData(name: InfoKey.baseCurrencyID.id, value: String(setup.currencyId.value)),
            InfotableData(name: InfoKey.defaultAccountID.id, value: String(account.id.value)),
            InfotableData(name: InfoKey.createDate.id, value: DateString(Date()).string),
            InfotableData(name: InfoKey.categDelimiter.id, value: ":"),
            InfotableData(name: InfoKey.uid.id, value: "ios_\(UUID().uuidString)")
        ]
        for setting in settings {
            try connection.run(InfotableRepository.table.insert(InfotableRepository.itemSetters(setting)))
        }
        guard repository.setPragma(name: "journal_mode", value: "MEMORY") else {
            throw setupError("Cannot initialize the first account or database settings")
        }
        return connection
    }

    private func releaseDatabaseAccess() {
        securityScopedDatabaseURL?.stopAccessingSecurityScopedResource()
        securityScopedDatabaseURL = nil
    }

    private func setupError(_ message: String) -> NSError {
        NSError(domain: "MMEX.DatabaseSetup", code: 1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString(message, comment: "Database setup error")
        ])
    }

    private func isLocalDocument(_ url: URL) -> Bool {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let directory = documents.standardizedFileURL.path + "/"
        return url.standardizedFileURL.path.hasPrefix(directory)
    }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Write any unsaved changes back to the original file
        if let databaseURL = databaseURL {
            log.info("Attempting to merge changes to: \(databaseURL.path)")
            // Ensure the file is a security-scoped resource
            let hasScopedAccess = databaseURL.startAccessingSecurityScopedResource()
            if hasScopedAccess || isLocalDocument(databaseURL) {
                defer { if hasScopedAccess { databaseURL.stopAccessingSecurityScopedResource() } }

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
        releaseDatabaseAccess()
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

    @discardableResult
    private func saveBookmark(for url: URL) -> Bool {
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "DatabaseBookmark")
            log.info("Bookmark saved successfully.")
            return true
        } catch {
            log.error("Failed to save bookmark: \(error)")
            return false
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
