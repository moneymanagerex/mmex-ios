//
//  Repository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct Repository {
    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }
}

extension Repository {
    var userVersion: Int32? { db.userVersion }

    func select<Result>(
        from table: SQLite.Table,
        with result: (SQLite.Row) -> Result
    ) -> [Result] {
        do {
            var data: [Result] = []
            for row in try db.prepare(table) {
                data.append(result(row))
            }
            print("Successfull select: \(data.count)")
            return data
        } catch {
            print("Failed select: \(error)")
            return []
        }
    }

    func execute(sql: String) {
        print("Executing sql: \(sql)")
        do {
            try db.execute(sql)
        } catch {
            print("Failed to execute sql: \(error)")
        }
    }

    func execute(url: URL) {
        guard let contents = try? String(contentsOf: url) else {
            print("Failed to read \(url)")
            return
        }

        // split contents into paragraphs and execute each paragraph
        var paragraph = ""
        for line in contents.components(separatedBy: "\n") {
            if line.starts(with: "--") { continue }
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !paragraph.isEmpty {
                    execute(sql: paragraph)
                    paragraph = ""
                }
            } else {
                if !paragraph.isEmpty { paragraph.append("\n") }
                paragraph.append(line)
            }
        }
        if !paragraph.isEmpty {
            execute(sql: paragraph)
        }
    }

    func create(sampleData: Bool = false) {
        db.userVersion = 19
        guard let tables = Bundle.main.url(forResource: "tables.sql", withExtension: "") else {
            print("Cannot find tables.sql")
            return
        }
        execute(url: tables)
        if sampleData { insertSampleData() }
    }
}

extension Repository {
    func insertSampleData() {

        var infotableMap: [Int64: Int64] = [:]
        do {
            let repo = InfotableRepository(db)
            repo.deleteAll()
            for var data in InfotableData.sampleData {
                let id = data.id
                repo.insert(&data)
                infotableMap[id] = data.id
            }
        }

        var currencyMap: [Int64: Int64] = [:]
        do {
            let repo = CurrencyRepository(db)
            repo.deleteAll()
            for var data in CurrencyData.sampleData {
                let id = data.id
                repo.insert(&data)
                currencyMap[id] = data.id
            }
        }

        var currencyHistoryMap: [Int64: Int64] = [:]
        do {
            let repo = CurrencyHistoryRepository(db)
            repo.deleteAll()
            for var data in CurrencyHistoryData.sampleData {
                let id = data.id
                data.currencyId = currencyMap[data.currencyId] ?? data.currencyId
                repo.insert(&data)
                currencyHistoryMap[id] = data.id
            }
        }

        var accountMap: [Int64: Int64] = [:]
        do {
            let repo = AccountRepository(db)
            repo.deleteAll()
            for var data in AccountData.sampleData {
                let id = data.id
                data.currencyId = currencyMap[data.currencyId] ?? data.currencyId
                repo.insert(&data)
                accountMap[id] = data.id
            }
        }

        var assetMap: [Int64: Int64] = [:]
        do {
            let repo = AssetRepository(db)
            repo.deleteAll()
            for var data in AssetData.sampleData {
                let id = data.id
                data.currencyId = currencyMap[data.currencyId] ?? data.currencyId
                repo.insert(&data)
                assetMap[id] = data.id
            }
        }

        var stockMap: [Int64: Int64] = [:]
        do {
            let repo = StockRepository(db)
            repo.deleteAll()
            for var data in StockData.sampleData {
                let id = data.id
                data.accountId = accountMap[data.accountId] ?? data.accountId
                repo.insert(&data)
                stockMap[id] = data.id
            }
        }

        var stockHistoryMap: [Int64: Int64] = [:]
        do {
            let repo = StockHistoryRepository(db)
            repo.deleteAll()
            for var data in StockHistoryData.sampleData {
                let id = data.id
                repo.insert(&data)
                stockHistoryMap[id] = data.id
            }
        }

        var categoryMap: [Int64: Int64] = [:]
        do {
            let repo = CategoryRepository(db)
            repo.deleteAll()
            for var data in CategoryData.sampleData {
                let id = data.id
                data.parentId = categoryMap[data.parentId] ?? data.parentId
                repo.insert(&data)
                categoryMap[id] = data.id
            }
        }

        var payeeMap: [Int64: Int64] = [:]
        do {
            let repo = PayeeRepository(db)
            repo.deleteAll()
            for var data in PayeeData.sampleData {
                let id = data.id
                data.categoryId = categoryMap[data.categoryId] ?? data.categoryId
                repo.insert(&data)
                payeeMap[id] = data.id
            }
        }

        var transactionMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionRepository(db)
            repo.deleteAll()
            for var data in TransactionData.sampleData {
                let id = data.id
                data.accountId   = accountMap[data.accountId]   ?? data.accountId
                data.toAccountId = accountMap[data.toAccountId] ?? data.toAccountId
                data.payeeId     = payeeMap[data.payeeId]       ?? data.payeeId
                data.categId     = categoryMap[data.categId]    ?? data.categId
                repo.insert(&data)
                transactionMap[id] = data.id
            }
        }

        var transactionSplitMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionSplitRepository(db)
            repo.deleteAll()
            for var data in TransactionSplitData.sampleData {
                let id = data.id
                data.transId = transactionMap[data.transId] ?? data.transId
                data.categId = categoryMap[data.categId]    ?? data.categId
                repo.insert(&data)
                transactionSplitMap[id] = data.id
            }
        }

        var transactionLinkMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionLinkRepository(db)
            repo.deleteAll()
            for var data in TransactionLinkData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .stock : stockMap[data.refId] ?? data.refId
                case .asset : assetMap[data.refId] ?? data.refId
                default: data.refId
                }
                repo.insert(&data)
                transactionLinkMap[id] = data.id
            }
        }

        var transactionShareMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionShareRepository(db)
            repo.deleteAll()
            for var data in TransactionShareData.sampleData {
                let id = data.id
                data.transId = transactionMap[data.transId] ?? data.transId
                repo.insert(&data)
                transactionShareMap[id] = data.id
            }
        }

        var scheduledMap: [Int64: Int64] = [:]
        do {
            let repo = ScheduledRepository(db)
            repo.deleteAll()
            for var data in ScheduledData.sampleData {
                let id = data.id
                data.accountId   = accountMap[data.accountId]   ?? data.accountId
                data.toAccountId = accountMap[data.toAccountId] ?? data.toAccountId
                data.payeeId     = payeeMap[data.payeeId]       ?? data.payeeId
                data.categId     = categoryMap[data.categId]    ?? data.categId
                repo.insert(&data)
                scheduledMap[id] = data.id
            }
        }

        var scheduledSplitMap: [Int64: Int64] = [:]
        do {
            let repo = ScheduledSplitRepository(db)
            repo.deleteAll()
            for var data in ScheduledSplitData.sampleData {
                let id = data.id
                data.schedId = scheduledMap[data.schedId] ?? data.schedId
                data.categId = categoryMap[data.categId]  ?? data.categId
                repo.insert(&data)
                scheduledSplitMap[id] = data.id
            }
        }

        var tagMap: [Int64: Int64] = [:]
        do {
            let repo = TagRepository(db)
            repo.deleteAll()
            for var data in TagData.sampleData {
                let id = data.id
                repo.insert(&data)
                tagMap[id] = data.id
            }
        }

        var tagLinkMap: [Int64: Int64] = [:]
        do {
            let repo = TagLinkRepository(db)
            repo.deleteAll()
            for var data in TagLinkData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .transaction      : transactionMap[data.refId]      ?? data.refId
                case .transactionSplit : transactionSplitMap[data.refId] ?? data.refId
                case .scheduled        : scheduledMap[data.refId]        ?? data.refId
                case .scheduledSplit   : scheduledSplitMap[data.refId]   ?? data.refId
                default: data.refId
                }
                repo.insert(&data)
                tagLinkMap[id] = data.id
            }
        }

        var fieldMap: [Int64: Int64] = [:]
        do {
            let repo = FieldRepository(db)
            repo.deleteAll()
            for var data in FieldData.sampleData {
                let id = data.id
                repo.insert(&data)
                fieldMap[id] = data.id
            }
        }

        var fieldContentMap: [Int64: Int64] = [:]
        do {
            let repo = FieldContentRepository(db)
            repo.deleteAll()
            for var data in FieldContentData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .transaction : transactionMap[data.refId] ?? data.refId
                case .scheduled   : scheduledMap[data.refId]   ?? data.refId
                default: data.refId
                }
                data.fieldId = fieldMap[data.fieldId] ?? data.fieldId
                repo.insert(&data)
                fieldContentMap[id] = data.id
            }
        }

        var attachmentMap: [Int64: Int64] = [:]
        do {
            let repo = AttachmentRepository(db)
            repo.deleteAll()
            for var data in AttachmentData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .transaction      : transactionMap[data.refId]      ?? data.refId
                case .stock            : stockMap[data.refId]            ?? data.refId
                case .asset            : assetMap[data.refId]            ?? data.refId
                case .account          : accountMap[data.refId]          ?? data.refId
                case .scheduled        : scheduledMap[data.refId]        ?? data.refId
                case .payee            : payeeMap[data.refId]            ?? data.refId
                case .transactionSplit : transactionSplitMap[data.refId] ?? data.refId
                case .scheduledSplit   : scheduledSplitMap[data.refId]   ?? data.refId
                }
                repo.insert(&data)
                attachmentMap[id] = data.id
            }
        }

        var budgetYearMap: [Int64: Int64] = [:]
        do {
            let repo = BudgetYearRepository(db)
            repo.deleteAll()
            for var data in BudgetYearData.sampleData {
                let id = data.id
                repo.insert(&data)
                budgetYearMap[id] = data.id
            }
        }

        var budgetTableMap: [Int64: Int64] = [:]
        do {
            let repo = BudgetTableRepository(db)
            repo.deleteAll()
            for var data in BudgetTableData.sampleData {
                let id = data.id
                data.yearId  = budgetYearMap[data.yearId] ?? data.yearId
                data.categId = categoryMap[data.categId]  ?? data.categId
                repo.insert(&data)
                budgetTableMap[id] = data.id
            }
        }

        var reportMap: [Int64: Int64] = [:]
        do {
            let repo = ReportRepository(db)
            repo.deleteAll()
            for var data in ReportData.sampleData {
                let id = data.id
                repo.insert(&data)
                reportMap[id] = data.id
            }
        }
    }
}
