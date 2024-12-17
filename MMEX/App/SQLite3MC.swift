//
//  SQLite3MC.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/12/17.
//

import SQLite

/// Extension methods for sqlite3mc (SQLite3 Multiple Ciphers).
/// This extension interacts with the encrypted SQLite database using sqlite3mc.
extension Connection {

    // Function to initialize the cipher with the default version and legacy mode
    public func initializeCipher() {
        sqlite3mc_config(handle, "default:cipher", sqlite3mc_cipher_index("sqlcipher"))
        sqlite3mc_config_cipher(handle, "sqlcipher", "legacy", 4);
    }
    
    /// Set the encryption key for the database. This should be called immediately after opening the database.
    ///
    /// - Parameters:
    ///   - key: The encryption key, typically a passphrase or a raw byte sequence.
    ///   - db: The name of the database, defaults to "main".
    public func key(_ key: String, db: String = "main") throws {
        try check(sqlite3_key_v2(handle, db, key, Int32(key.utf8.count)))
        try cipher_key_check()
    }

    public func key(_ key: Blob, db: String = "main") throws {
        try check(sqlite3_key_v2(handle, db, key.bytes, Int32(key.bytes.count)))
        try cipher_key_check()
    }

    /// Same as `key(_ key: String, db: String)`, but runs `PRAGMA cipher_migrate;` immediately after
    /// setting the key, to migrate the database schema if it's created with an older version of sqlite3mc.
    public func keyAndMigrate(_ key: String, db: String = "main") throws {
        // Set the key first
        try self.key(key, db: db)

        // Migrate the database schema
        let migrateResult = try scalar("PRAGMA cipher_migrate;")
        if let result = migrateResult as? String, result != "0" {
            throw Result.error(message: "Error in cipher migration, result \(result.debugDescription)", code: 1, statement: nil)
        }
    }

    public func keyAndMigrate(_ key: Blob, db: String = "main") throws {
        // Set the key first
        try self.key(key, db: db)

        // Migrate the database schema
        let migrateResult = try scalar("PRAGMA cipher_migrate;")
        if let result = migrateResult as? String, result != "0" {
            throw Result.error(message: "Error in cipher migration, result \(result.debugDescription)", code: 1, statement: nil)
        }
    }

    /// Change the key on an already encrypted database.
    ///
    /// - Parameters:
    ///   - key: The new encryption key.
    ///   - db: The name of the database, defaults to "main".
    public func rekey(_ key: String, db: String = "main") throws {
        try check(sqlite3_rekey_v2(handle, db, key, Int32(key.utf8.count)))
    }

    public func rekey(_ key: Blob, db: String = "main") throws {
        try check(sqlite3_rekey_v2(handle, db, key.bytes, Int32(key.bytes.count)))
    }

    /// Export an encrypted database to another location.
    ///
    /// - Parameters:
    ///   - location: The location to export the database to.
    ///   - key: The encryption key for the exported database.
    public func exportEncryptedDatabase(to location: Location, key: String) throws {
        let schemaName = "cipher_export"
        try attach(location, as: schemaName)
        try run("SELECT sqlite3mc_export(?)", schemaName)
        try detach(schemaName)
    }

    // MARK: - Private methods
    private func check(_ resultCode: Int32) throws {
        guard resultCode == SQLITE_OK else {
            throw Result.error(message: "SQLite3 Error: \(resultCode)", code: resultCode, statement: nil)
        }
    }

    // Check if the key works by performing a simple query (using SELECT count(*) from sqlite_master).
    private func cipher_key_check() throws {
        _ = try scalar("SELECT count(*) FROM sqlite_master;")
    }
}
