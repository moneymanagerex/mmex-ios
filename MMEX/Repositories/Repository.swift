//
//  RepositoryProtocaol.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class Repository {
    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }
}

extension Repository {
    func select<Result>(
        from table: SQLite.Table,
        with result: (SQLite.Row) -> Result
    ) -> [Result] {
        guard let db else { return [] }
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
        guard let db else { return }
        print("Executing sql: \(sql)")
        do {
            try db.execute(sql)
        } catch {
            print("Failed to execute sql: \(error)")
        }
    }

    func execute(url: URL) {
        if db == nil { return }
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
}

protocol RepositoryProtocol {
    associatedtype RepositoryData: DataProtocol

    var db: Connection? { get }

    static var repositoryName: String { get }
    static var table: SQLite.Table { get }
    static func selectQuery(from table: SQLite.Table) -> SQLite.Table
    static func selectData(_ row: SQLite.Row) -> RepositoryData
    static var col_id: SQLite.Expression<Int64> { get }
    static func itemSetters(_ item: RepositoryData) -> [SQLite.Setter]
}

extension RepositoryProtocol {
    func pluck(from table: SQLite.Table, key: String) -> RepositoryData? {
        guard let db else { return nil }
        do {
            if let row = try db.pluck(Self.selectQuery(from: table)) {
                let data = Self.selectData(row)
                print("Successfull pluck for \(key) in \(Self.repositoryName): \(data.shortDesc())")
                return data
            } else {
                print("Unsuccefull pluck for \(key) in \(Self.repositoryName)")
                return nil
            }
        } catch {
            print("Failed pluck for \(key) in \(Self.repositoryName): \(error)")
            return nil
        }
    }

    func pluck(id: Int64) -> RepositoryData? {
        guard let db else { return nil }
        do {
            if let row = try db.pluck(Self.selectQuery(from: Self.table)
                .filter(Self.col_id == id)
            ) {
                let data = Self.selectData(row)
                print("Successfull pluck for id \(id) in \(Self.repositoryName): \(data.shortDesc())")
                return data
            } else {
                print("Unsuccefull pluck for id \(id) in \(Self.repositoryName)")
                return nil
            }
        } catch {
            print("Failed pluck for id \(id) in \(Self.repositoryName): \(error)")
            return nil
        }
    }

    func select(from table: SQLite.Table) -> [RepositoryData] {
        guard let db else { return [] }
        do {
            var data: [RepositoryData] = []
            for row in try db.prepare(Self.selectQuery(from: table)) {
                data.append(Self.selectData(row))
            }
            print("Successfull select from \(Self.repositoryName): \(data.count)")
            return data
        } catch {
            print("Failed select from \(Self.repositoryName): \(error)")
            return []
        }
    }

    @discardableResult
    func insert(_ data: inout RepositoryData) -> Bool {
        guard let db else { return false }
        do {
            let query = Self.table
                .insert(Self.itemSetters(data))
            let rowid = try db.run(query)
            data.id = rowid
            print("Successfull insert in \(RepositoryData.dataName): \(data.shortDesc())")
            return true
        } catch {
            print("Failed insert in \(RepositoryData.dataName): \(error)")
            return false
        }
    }

    @discardableResult
    func update(_ data: RepositoryData) -> Bool {
        guard let db else { return false }
        guard data.id > 0 else { return false }
        do {
            let query = Self.table
                .filter(Self.col_id == data.id)
                .update(Self.itemSetters(data))
            try db.run(query)
            print("Successfull update in \(RepositoryData.dataName): \(data.shortDesc())")
            return true
        } catch {
            print("Failed update in \(RepositoryData.dataName): \(error)")
            return false
        }
    }

    @discardableResult
    func delete(_ data: RepositoryData) -> Bool {
        guard let db else { return false }
        guard data.id > 0 else { return false }
        do {
            let query = Self.table
                .filter(Self.col_id == data.id)
                .delete()
            try db.run(query)
            print("Successfull delete in \(RepositoryData.dataName): \(data.shortDesc())")
            return true
        } catch {
            print("Failed delete in \(RepositoryData.dataName): \(error)")
            return false
        }
    }

    @discardableResult
    func deleteAll() -> Bool {
        guard let db else { return false }
        do {
            let query = Self.table.delete()
            try db.run(query)
            print("Successfull delete all in \(RepositoryData.dataName)")
            return true
        } catch {
            print("Failed delete all in \(RepositoryData.dataName): \(error)")
            return false
        }
    }
}

extension Repository {
    func insertSampleData() {

        var infotableMap: [Int64: Int64] = [:]
        do {
            let repo = InfotableRepository(db: db)
            repo.deleteAll()
            for var data in InfotableData.sampleData {
                let id = data.id
                repo.insert(&data)
                infotableMap[id] = data.id
            }
        }

        var currencyMap: [Int64: Int64] = [:]
        do {
            let repo = CurrencyRepository(db: db)
            repo.deleteAll()
            for var data in CurrencyData.sampleData {
                let id = data.id
                repo.insert(&data)
                currencyMap[id] = data.id
            }
        }

        var currencyHistoryMap: [Int64: Int64] = [:]
        do {
            let repo = CurrencyHistoryRepository(db: db)
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
            let repo = AccountRepository(db: db)
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
            let repo = AssetRepository(db: db)
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
            let repo = StockRepository(db: db)
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
            let repo = StockHistoryRepository(db: db)
            repo.deleteAll()
            for var data in StockHistoryData.sampleData {
                let id = data.id
                repo.insert(&data)
                stockHistoryMap[id] = data.id
            }
        }

        var categoryMap: [Int64: Int64] = [:]
        do {
            let repo = CategoryRepository(db: db)
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
            let repo = PayeeRepository(db: db)
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
            let repo = TransactionRepository(db: db)
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
            let repo = TransactionSplitRepository(db: db)
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
            let repo = TransactionLinkRepository(db: db)
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

        var scheduledMap: [Int64: Int64] = [:]
        do {
            let repo = ScheduledRepository(db: db)
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
            let repo = ScheduledSplitRepository(db: db)
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
            let repo = TagRepository(db: db)
            repo.deleteAll()
            for var data in TagData.sampleData {
                let id = data.id
                repo.insert(&data)
                tagMap[id] = data.id
            }
        }

        var tagLinkMap: [Int64: Int64] = [:]
        do {
            let repo = TagLinkRepository(db: db)
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

        var attachmentMap: [Int64: Int64] = [:]
        do {
            let repo = AttachmentRepository(db: db)
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
            let repo = BudgetYearRepository(db: db)
            repo.deleteAll()
            for var data in BudgetYearData.sampleData {
                let id = data.id
                repo.insert(&data)
                budgetYearMap[id] = data.id
            }
        }

        var budgetTableMap: [Int64: Int64] = [:]
        do {
            let repo = BudgetTableRepository(db: db)
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
            let repo = ReportRepository(db: db)
            repo.deleteAll()
            for var data in ReportData.sampleData {
                let id = data.id
                repo.insert(&data)
                reportMap[id] = data.id
            }
        }
    }
}

/*
extension RepositoryProtocol {
    func create() {
        guard let db else { return }
        var query: String = "CREATE TABLE \(Self.repositoryName)("
        var comma = false
        for (name, type, other) in Self.columns {
            if comma { query.append(", ") }
            var space = false
            if !name.isEmpty {
                query.append("\(name) \(type)")
                space = true
            }
            if !other.isEmpty {
                if space { query.append(" ") }
                query.append("\(other)")
            }
            comma = true
        }
        query.append(")")
        print("Executing query: \(query)")
        do {
            try db.execute(query)
        } catch {
            print("Failed to create table \(Self.repositoryName): \(error)")
        }
    }
*/
