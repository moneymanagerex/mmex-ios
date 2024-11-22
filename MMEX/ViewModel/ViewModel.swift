//
//  ViewModel.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite
import Combine

@MainActor
class ViewModel: ObservableObject {
    let env: EnvironmentManager
    //var subscriptions = Set<AnyCancellable>()

    @Published var journalList  : LoadState = .init()
    @Published var insightsList : LoadState = .init()
    @Published var enterList    : LoadState = .init()
    @Published var manageList   : LoadState = .init()
    @Published var settingsList : LoadState = .init()

    typealias I = InfotableRepository
    @Published var infotableList : InfotableList  = .init()

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
    typealias TP = TransactionSplitRepository
    typealias TL = TransactionLinkRepository
    typealias TS = TransactionShareRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionList  : TransactionList  = .init()
    //@Published var transactionGroup : TransactionGroup = .init()

    typealias Q = ScheduledRepository
    typealias QP = ScheduledSplitRepository
    @Published var scheduledList  : ScheduledList  = .init()
    //@Published var scheduledGroup : ScheduledGroup = .init()

    typealias G = TagRepository
    typealias GL = TagLinkRepository
    @Published var tagList  : TagList  = .init()
    @Published var tagGroup : TagGroup = .init()

    typealias F = FieldRepository
    typealias FV = FieldValueRepository
    @Published var fieldList  : FieldList  = .init()
    @Published var fieldGroup : FieldGroup = .init()

    typealias D = AttachmentRepository
    @Published var attachmentList  : AttachmentList  = .init()
    @Published var attachmentGroup : AttachmentGroup = .init()

    typealias BP = BudgetPeriodRepository
    @Published var budgetPeriodList  : BudgetPeriodList  = .init()
    @Published var budgetPeriodGroup : BudgetPeriodGroup = .init()

    typealias B = BudgetRepository
    @Published var budgetList  : BudgetList  = .init()
    @Published var budgetGroup : BudgetGroup = .init()

    typealias R = ReportRepository
    @Published var reportList  : ReportList  = .init()

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
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].fetchValue(env: self.env)
        if let value {
            self[keyPath: keyPath].value = value
        }
        let ok = value != nil
        self[keyPath: keyPath].state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        }
        return ok
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].evalValue(env: self.env, vm: self)
        if let value {
            self[keyPath: keyPath].value = value
        }
        let ok = value != nil
        self[keyPath: keyPath].state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        }
        return ok
    }

    func load<RepositoryLoadType: LoadFetchProtocol>(
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].fetchValue(env: self.env)
            let ok = value != nil
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: ok)
            }
            if ok {
                log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            } else {
                log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            }
            return ok
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
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].evalValue(env: self.env, vm: self)
            let ok = value != nil
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: ok)
            }
            if ok {
                log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            } else {
                log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            }
            return ok
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
        if let data = data as? InfotableData {
            return data.name
        } else if let data = data as? CurrencyData {
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
