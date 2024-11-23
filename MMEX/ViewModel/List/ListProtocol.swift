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
    func loadList<ListType: ListProtocol>(_ pref: Preference, _ listType: ListType.Type) async {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == I.self  { await loadInfotableList(pref) }
        else if MainRepository.self == U.self  { await loadCurrencyList(pref) }
        else if MainRepository.self == A.self  { await loadAccountList(pref) }
        else if MainRepository.self == E.self  { await loadAssetList(pref) }
        else if MainRepository.self == S.self  { await loadStockList(pref) }
        else if MainRepository.self == C.self  { await loadCategoryList(pref) }
        else if MainRepository.self == P.self  { await loadPayeeList(pref) }
        else if MainRepository.self == T.self  { await loadTransactionList(pref) }
        else if MainRepository.self == Q.self  { await loadScheduledList(pref) }
        else if MainRepository.self == G.self  { await loadTagList(pref) }
        else if MainRepository.self == F.self  { await loadFieldList(pref) }
        else if MainRepository.self == D.self  { await loadAttachmentList(pref) }
        else if MainRepository.self == BP.self { await loadBudgetPeriodList(pref) }
        else if MainRepository.self == B.self  { await loadBudgetList(pref) }
        else if MainRepository.self == R.self  { await loadReportList(pref) }
    }

    func unloadList<ListType: ListProtocol>(_ listType: ListType.Type) {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == I.self  { unloadInfotableList() }
        else if MainRepository.self == U.self  { unloadCurrencyList() }
        else if MainRepository.self == A.self  { unloadAccountList() }
        else if MainRepository.self == E.self  { unloadAssetList() }
        else if MainRepository.self == S.self  { unloadStockList() }
        else if MainRepository.self == C.self  { unloadCategoryList() }
        else if MainRepository.self == P.self  { unloadPayeeList() }
        else if MainRepository.self == T.self  { unloadTransactionList() }
        else if MainRepository.self == Q.self  { unloadScheduledList() }
        else if MainRepository.self == G.self  { unloadTagList() }
        else if MainRepository.self == F.self  { unloadFieldList() }
        else if MainRepository.self == D.self  { unloadAttachmentList() }
        else if MainRepository.self == BP.self { unloadBudgetPeriodList() }
        else if MainRepository.self == B.self  { unloadBudgetList() }
        else if MainRepository.self == R.self  { unloadReportList() }
    }

    func loadList(_ pref: Preference) async {
        await loadInfotableList(pref)
        await loadCurrencyList(pref)
        await loadAccountList(pref)
        await loadAssetList(pref)
        await loadStockList(pref)
        await loadCategoryList(pref)
        await loadPayeeList(pref)
        await loadTransactionList(pref)
        await loadScheduledList(pref)
        await loadTagList(pref)
        await loadFieldList(pref)
        await loadAttachmentList(pref)
        await loadBudgetPeriodList(pref)
        await loadBudgetList(pref)
        await loadReportList(pref)
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
        unloadBudgetPeriodList()
        unloadBudgetList()
        unloadReportList()
    }
}
