//
//  ViewModel.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

@MainActor
class ViewModel: ObservableObject {
    let env: EnvironmentManager

    @Published var manageList: LoadState = .init()

    typealias I = InfotableRepository

    typealias U = CurrencyRepository
    typealias UH = CurrencyHistoryRepository
    @Published var currencyList  : CurrencyList  = .init()
    @Published var currencyGroup : CurrencyGroup = .init()

    typealias A = AccountRepository
    @Published var accountList  : AccountList  = .init()
    @Published var accountGroup : AccountGroup = .init()

    typealias E = AssetRepository
    @Published var assetList  : AssetList  = .init()
    @Published var assetGroup : AssetGroup = .init()

    typealias S = StockRepository
    typealias SH = StockHistoryRepository
    @Published var stockList  : StockList  = .init()
    @Published var stockGroup : StockGroup = .init()

    typealias C = CategoryRepository
    @Published var categoryList  : CategoryList  = .init()
    @Published var categoryGroup : CategoryGroup = .init()

    typealias P = PayeeRepository
    @Published var payeeList  : PayeeList  = .init()
    @Published var payeeGroup : PayeeGroup = .init()

    typealias T = TransactionRepository
    typealias TS = TransactionSplitRepository
    typealias TL = TransactionLinkRepository
    typealias TH = TransactionShareRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionCount : LoadMainCount<T> = .init(table: T_table)

    typealias R = ScheduledRepository
    typealias RS = ScheduledSplitRepository
    @Published var scheduledCount : LoadMainCount<R> = .init()

    typealias G = TagRepository
    typealias GL = TagLinkRepository
    typealias F = FieldRepository
    typealias FD = FieldContentRepository
    typealias AX = AttachmentRepository
    typealias Y = BudgetYearRepository
    typealias B = BudgetTableRepository
    typealias O = ReportRepository

    init(env: EnvironmentManager) {
        self.env = env
    }
}

extension ViewModel {
    func load<RepositoryLoadType: LoadFetchProtocol>(
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].fetchValue(env: self.env)
        if let value {
            self[keyPath: keyPath].value = value
        }
        self[keyPath: keyPath].state.loaded(ok: value != nil)
        return value != nil
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].evalValue(env: self.env, vm: self)
        if let value {
            self[keyPath: keyPath].value = value
        }
        self[keyPath: keyPath].state.loaded(ok: value != nil)
        return value != nil
    }

    func load<RepositoryLoadType: LoadFetchProtocol>(
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].fetchValue(env: self.env)
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: value != nil)
            }
            return value != nil
        }
        return true
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].evalValue(env: self.env, vm: self)
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: value != nil)
            }
            return value != nil
        }
        return true
    }

    func taskGroupOk(_ taskGroup: TaskGroup<Bool>, _ ok: Bool = true) async -> Bool {
        var ok = ok
        for await taskOk in taskGroup {
            if !taskOk { ok = false }
        }
        return ok
    }
}

extension ViewModel {
    func name<DataType: DataProtocol>(_ data: DataType) -> String {
        if let data = data as? CurrencyData {
            return data.name
        } else if let data = data as? AccountData {
            return data.name
        } else if let data = data as? AssetData {
            return data.name
        } else if let data = data as? StockData {
            return data.name
        } else if let data = data as? CategoryData {
            // TODO: name -> path
            return data.name
        } else if let data = data as? PayeeData {
            return data.name
        }
        return ""
    }

    func filename<DataType: DataProtocol>(_ data: DataType) -> String {
        return "\(name(data))_\(DataType.dataName.0)"
    }
}
