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

    mutating func unloadNone()
    mutating func unloadAll()
    func isUsed(_ id: DataId) -> Bool?
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
}

extension ListProtocol {
    mutating func unloadNone() {
        guard unloading() else { return }
        unloaded()
    }

    // default implementation
    mutating func unloadAll() {
        guard reloading() else { return }
        unloaded()
    }

    // default implementation
    func isUsed(_ dataId: DataId) -> Bool? {
        return used.readyValue?.contains(dataId)
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

    func unloadList<ListType: ListProtocol>(_ listType: ListType.Type) {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == I.self  { infotableList.unloadAll() }
        else if MainRepository.self == U.self  { currencyList.unloadAll() }
        else if MainRepository.self == A.self  { accountList.unloadAll() }
        else if MainRepository.self == E.self  { assetList.unloadAll() }
        else if MainRepository.self == S.self  { stockList.unloadAll() }
        else if MainRepository.self == C.self  { categoryList.unloadAll() }
        else if MainRepository.self == P.self  { payeeList.unloadAll() }
        else if MainRepository.self == T.self  { transactionList.unloadAll() }
        else if MainRepository.self == Q.self  { scheduledList.unloadAll() }
        else if MainRepository.self == G.self  { tagList.unloadAll() }
        else if MainRepository.self == F.self  { fieldList.unloadAll() }
        else if MainRepository.self == D.self  { attachmentList.unloadAll() }
        else if MainRepository.self == BP.self { budgetPeriodList.unloadAll() }
        else if MainRepository.self == B.self  { budgetList.unloadAll() }
        else if MainRepository.self == R.self  { reportList.unloadAll() }
    }

    func unloadList() {
        infotableList.unloadAll()
        currencyList.unloadAll()
        accountList.unloadAll()
        assetList.unloadAll()
        stockList.unloadAll()
        categoryList.unloadAll()
        payeeList.unloadAll()
        transactionList.unloadAll()
        scheduledList.unloadAll()
        tagList.unloadAll()
        fieldList.unloadAll()
        attachmentList.unloadAll()
        budgetPeriodList.unloadAll()
        budgetList.unloadAll()
        reportList.unloadAll()
    }
}
