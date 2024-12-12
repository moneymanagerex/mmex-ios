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

    init(db: Connection) {
        self.db = db
    }

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
            log.info("INFO: Repository.setPragma(\(name), \(value))")
            return true
        } catch {
            log.error("ERROR: Repository.setPragma(\(name), \(value)): \(error)")
            return false
        }
    }

    func select<Result>(
        from table: SQLite.Table,
        with result: (SQLite.Row) -> Result
    ) -> [Result]? {
        do {
            var data: [Result] = []
            log.trace("DEBUG: Repository.select(main=\(Thread.isMainThread)): \(table.expression.description)")
            for row in try db.prepare(table) {
                data.append(result(row))
            }
            log.info("INFO: Repository.select(): \(data.count)")
            return data
        } catch {
            log.error("ERROR: Repository.select(): \(error)")
            return nil
        }
    }

    func selectById<Result>(
        query: String,
        with result: (SQLite.Statement.Element) -> Result
    ) -> [DataId: Result]? {
        do {
            var dict: [DataId: Result] = [:]
            log.trace("DEBUG: Repository.selectById(main=\(Thread.isMainThread)): \(query)")
            for row in try db.prepare(query) {
                let id = DataId(row[0] as! Int64)
                dict[id] = result(row)
            }
            log.info("INFO: Repository.selectById(): \(dict.count)")
            return dict
        } catch {
            log.error("ERROR: Repository.selectById(): \(error)")
            return nil
        }
    }

    func execute(sql: String) -> Bool {
        do {
            log.trace("DEBUG: Repository.execute(main=\(Thread.isMainThread), sql:) \(sql)")
            try db.execute(sql)
            log.info("INFO: Repository.execute(sql:)")
            return true
        } catch {
            log.error("ERROR: Repository.execute(sql:): \(error)")
            return false
        }
    }

    func execute(url: URL) -> Bool {
        guard let contents = try? String(contentsOf: url) else {
            log.error("ERROR: Repository.execute(url:): cannot read \(url)")
            return false
        }
        log.trace("DEBUG: Repository.execute(main=\(Thread.isMainThread), url:) \(url))")

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
        log.trace("DEBUG: Repository.insertSampleData(main=\(Thread.isMainThread))")

        var infotableMap: [DataId: DataId] = [:]
        do {
            let repo = InfotableRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in InfotableData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                infotableMap[id] = data.id
            }
        }

        var currencyMap: [DataId: DataId] = [:]
        do {
            let repo = CurrencyRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in CurrencyData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                currencyMap[id] = data.id
            }
        }

        var currencyHistoryMap: [DataId: DataId] = [:]
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

        var accountMap: [DataId: DataId] = [:]
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

        var assetMap: [DataId: DataId] = [:]
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

        var stockMap: [DataId: DataId] = [:]
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

        var stockHistoryMap: [DataId: DataId] = [:]
        do {
            let repo = StockHistoryRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in StockHistoryData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                stockHistoryMap[id] = data.id
            }
        }

        var categoryMap: [DataId: DataId] = [:]
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

        var payeeMap: [DataId: DataId] = [:]
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

        var transactionMap: [DataId: DataId] = [:]
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

        var transactionSplitMap: [DataId: DataId] = [:]
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

        var transactionLinkMap: [DataId: DataId] = [:]
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

        var transactionShareMap: [DataId: DataId] = [:]
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

        var scheduledMap: [DataId: DataId] = [:]
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

        var scheduledSplitMap: [DataId: DataId] = [:]
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

        var tagMap: [DataId: DataId] = [:]
        do {
            let repo = TagRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in TagData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                tagMap[id] = data.id
            }
        }

        var tagLinkMap: [DataId: DataId] = [:]
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

        var fieldMap: [DataId: DataId] = [:]
        do {
            let repo = FieldRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in FieldData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                fieldMap[id] = data.id
            }
        }

        var fieldContentMap: [DataId: DataId] = [:]
        do {
            let repo = FieldValueRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in FieldValueData.sampleData {
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

        var attachmentMap: [DataId: DataId] = [:]
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

        var budgetYearMap: [DataId: DataId] = [:]
        do {
            let repo = BudgetPeriodRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in BudgetPeriodData.sampleData {
                let id = data.id
                guard repo.insert(&data) else { return false }
                budgetYearMap[id] = data.id
            }
        }

        var budgetTableMap: [DataId: DataId] = [:]
        do {
            let repo = BudgetRepository(db)
            guard repo.deleteAll() else { return false }
            for var data in BudgetData.sampleData {
                let id = data.id
                data.periodId  = budgetYearMap[data.periodId] ?? data.periodId
                data.categoryId = categoryMap[data.categoryId]  ?? data.categoryId
                guard repo.insert(&data) else { return false }
                budgetTableMap[id] = data.id
            }
        }

        var reportMap: [DataId: DataId] = [:]
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

extension Repository {
    func importData() -> Bool {
        log.trace("DEBUG: Repository.importData(main=\(Thread.isMainThread))")
        
        /// Payee
        do {
            let repo = PayeeRepository(db)
            let ids: [DataId] = repo.selectId<PayeeData>(from:PayeeRepository.table) ?? []
            
            let table = SQLite.Table(PayeeRepository.repositoryName, database: "attach")
            let results: [PayeeData]? = PayeeRepository(db).select<PayeeData>(from:table, with: PayeeRepository.fetchData)
            for var data in results ?? [] {
                /// assume no id conflicts after SUID
                if ids.contains(data.id) { continue }

                for _ in 1...3 {
                    if repo.insert(&data) {
                        break
                    } else {
                        /// TODO constraint awareness and update
                        log.error("ERROR: import failed for \(data.shortDesc())")
                        data.name = "\(data.name): \(data.id)"
                    }
                }
            }
        }

        return true
    }
}
