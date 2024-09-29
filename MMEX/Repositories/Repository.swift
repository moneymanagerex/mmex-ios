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
    func setUserVersion(_ userVersion: Int32) {
        db.userVersion = userVersion
    }

    func setPragma(name: String, value: String) -> Bool {
        do {
            try db.execute("PRAGMA \(name) = \(value)")
            print("Successful set \(name) to \(value)")
            return true
        } catch {
            print("Failed to set \(name): \(error)")
            return false
        }
    }

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

    func dict<Result>(
        query: String,
        with result: (SQLite.Statement.Element) -> Result
    ) -> [Int64: Result] {
        print("DEBUG: Repository.dict: \(query)")
        do {
            var dict: [Int64: Result] = [:]
            for row in try db.prepare(query) {
                dict[row[0] as! Int64] = result(row)
            }
            print("Successfull dictionary: \(dict.count)")
            return dict
        } catch {
            print("Failed dictionary: \(error)")
            return [:]
        }
    }

    func execute(sql: String) -> Bool {
        print("Executing sql: \(sql)")
        do {
            try db.execute(sql)
            return true
        } catch {
            print("Failed to execute sql: \(error)")
            return false
        }
    }

    func execute(url: URL) -> Bool {
        guard let contents = try? String(contentsOf: url) else {
            print("Failed to read \(url)")
            return false
        }

        // split contents into paragraphs and execute each paragraph
        var paragraph = ""
        for line in contents.components(separatedBy: "\n") {
            if line.starts(with: "--") { continue }
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !paragraph.isEmpty {
                    guard execute(sql: paragraph) else { return false }
                    paragraph = ""
                }
            } else {
                if !paragraph.isEmpty { paragraph.append("\n") }
                paragraph.append(line)
            }
        }
        if !paragraph.isEmpty {
            guard execute(sql: paragraph) else { return false }
        }
        return true
    }
}

extension Repository {
    func insertSampleData() -> Bool {

        var infotableMap: [Int64: Int64] = [:]
        do {
            let repo = InfotableRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in InfotableData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                infotableMap[id] = data.id
            }
        }

        var currencyMap: [Int64: Int64] = [:]
        do {
            let repo = CurrencyRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in CurrencyData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                currencyMap[id] = data.id
            }
        }

        var currencyHistoryMap: [Int64: Int64] = [:]
        do {
            let repo = CurrencyHistoryRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in CurrencyHistoryData.sampleData {
                let id = data.id
                data.currencyId = currencyMap[data.currencyId] ?? data.currencyId
                guard repo.insert(&data) else { return false }
                currencyHistoryMap[id] = data.id
            }
        }

        var accountMap: [Int64: Int64] = [:]
        do {
            let repo = AccountRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in AccountData.sampleData {
                let id = data.id
                data.currencyId = currencyMap[data.currencyId] ?? data.currencyId
                guard repo.insert(&data) else { return false }
                accountMap[id] = data.id
            }
        }

        var assetMap: [Int64: Int64] = [:]
        do {
            let repo = AssetRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in AssetData.sampleData {
                let id = data.id
                data.currencyId = currencyMap[data.currencyId] ?? data.currencyId
                guard repo.insert(&data) else { return false }
                assetMap[id] = data.id
            }
        }

        var stockMap: [Int64: Int64] = [:]
        do {
            let repo = StockRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in StockData.sampleData {
                let id = data.id
                data.accountId = accountMap[data.accountId] ?? data.accountId
                guard repo.insert(&data) else { return false }
                stockMap[id] = data.id
            }
        }

        var stockHistoryMap: [Int64: Int64] = [:]
        do {
            let repo = StockHistoryRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in StockHistoryData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                stockHistoryMap[id] = data.id
            }
        }

        var categoryMap: [Int64: Int64] = [:]
        do {
            let repo = CategoryRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in CategoryData.sampleData {
                let id = data.id
                data.parentId = categoryMap[data.parentId] ?? data.parentId
                guard repo.insert(&data) else { return false }
                categoryMap[id] = data.id
            }
        }

        var payeeMap: [Int64: Int64] = [:]
        do {
            let repo = PayeeRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in PayeeData.sampleData {
                let id = data.id
                data.categoryId = categoryMap[data.categoryId] ?? data.categoryId
                guard repo.insert(&data) else { return false }
                payeeMap[id] = data.id
            }
        }

        var transactionMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TransactionData.sampleData {
                let id = data.id
                data.accountId   = accountMap[data.accountId]   ?? data.accountId
                data.toAccountId = accountMap[data.toAccountId] ?? data.toAccountId
                data.payeeId     = payeeMap[data.payeeId]       ?? data.payeeId
                data.categId     = categoryMap[data.categId]    ?? data.categId
                guard repo.insert(&data) else { return false }
                transactionMap[id] = data.id
            }
        }

        var transactionSplitMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionSplitRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TransactionSplitData.sampleData {
                let id = data.id
                data.transId = transactionMap[data.transId] ?? data.transId
                data.categId = categoryMap[data.categId]    ?? data.categId
                guard repo.insert(&data) else { return false }
                transactionSplitMap[id] = data.id
            }
        }

        var transactionLinkMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionLinkRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TransactionLinkData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .stock : stockMap[data.refId] ?? data.refId
                case .asset : assetMap[data.refId] ?? data.refId
                default: data.refId
                }
                guard repo.insert(&data) else { return false }
                transactionLinkMap[id] = data.id
            }
        }

        var transactionShareMap: [Int64: Int64] = [:]
        do {
            let repo = TransactionShareRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TransactionShareData.sampleData {
                let id = data.id
                data.transId = transactionMap[data.transId] ?? data.transId
                guard repo.insert(&data) else { return false }
                transactionShareMap[id] = data.id
            }
        }

        var scheduledMap: [Int64: Int64] = [:]
        do {
            let repo = ScheduledRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in ScheduledData.sampleData {
                let id = data.id
                data.accountId   = accountMap[data.accountId]   ?? data.accountId
                data.toAccountId = accountMap[data.toAccountId] ?? data.toAccountId
                data.payeeId     = payeeMap[data.payeeId]       ?? data.payeeId
                data.categId     = categoryMap[data.categId]    ?? data.categId
                guard repo.insert(&data) else { return false }
                scheduledMap[id] = data.id
            }
        }

        var scheduledSplitMap: [Int64: Int64] = [:]
        do {
            let repo = ScheduledSplitRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in ScheduledSplitData.sampleData {
                let id = data.id
                data.schedId = scheduledMap[data.schedId] ?? data.schedId
                data.categId = categoryMap[data.categId]  ?? data.categId
                guard repo.insert(&data) else { return false }
                scheduledSplitMap[id] = data.id
            }
        }

        var tagMap: [Int64: Int64] = [:]
        do {
            let repo = TagRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TagData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                tagMap[id] = data.id
            }
        }

        var tagLinkMap: [Int64: Int64] = [:]
        do {
            let repo = TagLinkRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TagLinkData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .transaction      : transactionMap[data.refId]      ?? data.refId
                case .transactionSplit : transactionSplitMap[data.refId] ?? data.refId
                case .scheduled        : scheduledMap[data.refId]        ?? data.refId
                case .scheduledSplit   : scheduledSplitMap[data.refId]   ?? data.refId
                default: data.refId
                }
                guard repo.insert(&data) else { return false }
                tagLinkMap[id] = data.id
            }
        }

        var fieldMap: [Int64: Int64] = [:]
        do {
            let repo = FieldRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in FieldData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                fieldMap[id] = data.id
            }
        }

        var fieldContentMap: [Int64: Int64] = [:]
        do {
            let repo = FieldContentRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in FieldContentData.sampleData {
                let id = data.id
                data.refId = switch data.refType {
                case .transaction : transactionMap[data.refId] ?? data.refId
                case .scheduled   : scheduledMap[data.refId]   ?? data.refId
                default: data.refId
                }
                data.fieldId = fieldMap[data.fieldId] ?? data.fieldId
                guard repo.insert(&data) else { return false }
                fieldContentMap[id] = data.id
            }
        }

        var attachmentMap: [Int64: Int64] = [:]
        do {
            let repo = AttachmentRepository(db)
            guard repo.deleteAll() else { return false }
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
                guard repo.insert(&data) else { return false }
                attachmentMap[id] = data.id
            }
        }

        var budgetYearMap: [Int64: Int64] = [:]
        do {
            let repo = BudgetYearRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in BudgetYearData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                budgetYearMap[id] = data.id
            }
        }

        var budgetTableMap: [Int64: Int64] = [:]
        do {
            let repo = BudgetTableRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in BudgetTableData.sampleData {
                let id = data.id
                data.yearId  = budgetYearMap[data.yearId] ?? data.yearId
                data.categId = categoryMap[data.categId]  ?? data.categId
                guard repo.insert(&data) else { return false }
                budgetTableMap[id] = data.id
            }
        }

        var reportMap: [Int64: Int64] = [:]
        do {
            let repo = ReportRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in ReportData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                reportMap[id] = data.id
            }
        }

        return true
    }
}
