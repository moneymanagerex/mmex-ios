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
    private(set) var repository: Repository?
    private(set) var databaseURL: URL?

    init() {
        connectToStoredDatabase()
    }
    
    func openDatabase(at databaseURL: URL) {
        self.databaseURL = databaseURL
        repository = Repository(url: databaseURL)
        isDatabaseConnected = repository != nil
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
    
    func getSchemaVersion() -> Int32? { repository?.userVersion }

    /// Closes the current database connection and resets related states.
    func closeDatabase() {
        // Nullify the connection and reset the state
        repository = nil
        isDatabaseConnected = false
        databaseURL = nil
        print("Database connection closed.")
    }

    var infotableRepository        : InfotableRepository?        { repository?.infotableRepository }
    var currencyRepository         : CurrencyRepository?         { repository?.currencyRepository }
    var currencyHistoryRepository  : CurrencyRepository?         { repository?.currencyRepository }
    var accountRepository          : AccountRepository?          { repository?.accountRepository }
    var assetRepository            : AssetRepository?            { repository?.assetRepository }
    var stockRepository            : StockRepository?            { repository?.stockRepository }
    var stockHistoryRepository     : StockRepository?            { repository?.stockRepository }
    var categoryRepository         : CategoryRepository?         { repository?.categoryRepository }
    var payeeRepository            : PayeeRepository?            { repository?.payeeRepository }
    var transactionRepository      : TransactionRepository?      { repository?.transactionRepository }
    var transactionSplitRepository : TransactionSplitRepository? { repository?.transactionSplitRepository }
    var transactionLinkRepository  : TransactionLinkRepository?  { repository?.transactionLinkRepository }
    var transactionShareRepository : TransactionShareRepository? { repository?.transactionShareRepository }
    var scheduledRepository        : ScheduledRepository?        { repository?.scheduledRepository }
    var scheduledSplitRepository   : ScheduledSplitRepository?   { repository?.scheduledSplitRepository }
    var tagRepository              : TagRepository?              { repository?.tagRepository }
    var tagLinkRepository          : TagLinkRepository?          { repository?.tagLinkRepository }
    var fieldRepository            : FieldRepository?            { repository?.fieldRepository }
    var fieldContentRepository     : FieldContentRepository?     { repository?.fieldContentRepository }
    var attachmentRepository       : AttachmentRepository?       { repository?.attachmentRepository }
    var budgetYearRepository       : BudgetYearRepository?       { repository?.budgetYearRepository }
    var budgetTableRepository      : BudgetTableRepository?      { repository?.budgetTableRepository }
    var reportRepository           : ReportRepository?           { repository?.reportRepository }
}
