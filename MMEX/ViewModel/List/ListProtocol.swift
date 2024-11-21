//
//  ListProtocol.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

@MainActor
protocol ListProtocol {
    associatedtype MainRepository: RepositoryProtocol

    var state : LoadState                     { get set }
    var count : LoadMainCount<MainRepository> { get set }
    var data  : LoadMainData<MainRepository>  { get set }
    var used  : LoadMainUsed<MainRepository>  { get set }

    mutating func loading() -> Bool
    mutating func unloading() -> Bool
    mutating func reloading() -> Bool
    mutating func loaded(ok: Bool)
    mutating func unloaded()
    mutating func unload()
}

extension ListProtocol {
    static var listName: String { MainRepository.RepositoryData.dataName.0 }

    mutating func loading() -> Bool {
        guard state.loading() else { return false }
        //log.trace("DEBUG: ListProtocol.loading(\(Self.listName), main=\(Thread.isMainThread))")
        return true
    }

    mutating func unloading() -> Bool {
        guard state.unloading() else { return false }
        //log.trace("DEBUG: ListProtocol.unloading(\(Self.listName), main=\(Thread.isMainThread))")
        return true
    }

    mutating func reloading() -> Bool {
        guard state.reloading() else { return false }
        //log.trace("DEBUG: ListProtocol.reloading(\(Self.listName), main=\(Thread.isMainThread))")
        return true
    }

    mutating func loaded(ok: Bool = true) {
        state.loaded(ok: ok)
        if ok {
            log.info("INFO: ListProtocol.loaded(\(Self.listName), main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ListProtocol.loaded(\(Self.listName), main=\(Thread.isMainThread))")
        }
    }

    mutating func unloaded() {
        state.unloaded()
        log.info("INFO: ListProtocol.unloaded(\(Self.listName), main=\(Thread.isMainThread))")
    }

    mutating func unload() {
        guard state.unloading() else { return }
        state.unloaded()
    }
}

extension ViewModel {
    func reloadList<ListType: ListProtocol>(_ list: ListType) async {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == I.self { await reloadInfotableList() }
        else if MainRepository.self == U.self { await reloadCurrencyList() }
        else if MainRepository.self == A.self { await reloadAccountList() }
        else if MainRepository.self == E.self { await reloadAssetList() }
        else if MainRepository.self == S.self { await reloadStockList() }
        else if MainRepository.self == C.self { await reloadCategoryList() }
        else if MainRepository.self == P.self { await reloadPayeeList() }
        else if MainRepository.self == T.self { await reloadTransactionList() }
        else if MainRepository.self == Q.self { await reloadScheduledList() }
        else if MainRepository.self == G.self { await reloadTagList() }
        else if MainRepository.self == F.self { await reloadFieldList() }
        else if MainRepository.self == D.self { await reloadAttachmentList() }
        else if MainRepository.self == Y.self { await reloadYearList() }
        else if MainRepository.self == B.self { await reloadBudgetList() }
        else if MainRepository.self == R.self { await reloadReportList() }
    }

    func unloadList<ListType: ListProtocol>(_ list: ListType) {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == I.self { unloadInfotableList() }
        else if MainRepository.self == U.self { unloadCurrencyList() }
        else if MainRepository.self == A.self { unloadAccountList() }
        else if MainRepository.self == E.self { unloadAssetList() }
        else if MainRepository.self == S.self { unloadStockList() }
        else if MainRepository.self == C.self { unloadCategoryList() }
        else if MainRepository.self == P.self { unloadPayeeList() }
        else if MainRepository.self == T.self { unloadTransactionList() }
        else if MainRepository.self == Q.self { unloadScheduledList() }
        else if MainRepository.self == G.self { unloadTagList() }
        else if MainRepository.self == F.self { unloadFieldList() }
        else if MainRepository.self == D.self { unloadAttachmentList() }
        else if MainRepository.self == Y.self { unloadYearList() }
        else if MainRepository.self == B.self { unloadBudgetList() }
        else if MainRepository.self == R.self { unloadReportList() }
    }

    func reloadList() async {
        await reloadInfotableList()
        await reloadCurrencyList()
        await reloadAccountList()
        await reloadAssetList()
        await reloadStockList()
        await reloadCategoryList()
        await reloadPayeeList()
        await reloadTransactionList()
        await reloadScheduledList()
        await reloadTagList()
        await reloadFieldList()
        await reloadAttachmentList()
        await reloadYearList()
        await reloadBudgetList()
        await reloadReportList()

        await reloadJournalList()
        await reloadInsightsList()
        await reloadEnterList()
        await reloadManageList()
        await reloadSettingsList()
    }

    func unloadList() {
        unloadInfotableList()
        unloadCurrencyList()
        unloadAccountList()
        unloadAssetList()
        unloadStockList()
        unloadCategoryList()
        unloadPayeeList()
        unloadTransactionList()
        unloadScheduledList()
        unloadTagList()
        unloadFieldList()
        unloadAttachmentList()
        unloadYearList()
        unloadBudgetList()
        unloadReportList()
    }

    func clearList() {
        clearInfotableList()
        clearCurrencyList()
        clearAccountList()
        clearAssetList()
        clearStockList()
        clearCategoryList()
        clearPayeeList()
        clearTransactionList()
        clearScheduledList()
        clearTagList()
        clearFieldList()
        clearAttachmentList()
        clearYearList()
        clearBudgetList()
        clearReportList()
    }
}
