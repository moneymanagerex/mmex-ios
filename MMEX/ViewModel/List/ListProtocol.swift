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
        log.trace("DEBUG: ListProtocol.loading(\(Self.listName), main=\(Thread.isMainThread))")
        return true
    }

    mutating func unloading() -> Bool {
        guard state.unloading() else { return false }
        log.trace("DEBUG: ListProtocol.unloading(\(Self.listName), main=\(Thread.isMainThread))")
        return true
    }

    mutating func reloading() -> Bool {
        guard state.reloading() else { return false }
        log.trace("DEBUG: ListProtocol.reloading(\(Self.listName), main=\(Thread.isMainThread))")
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
    func loadList<ListType: ListProtocol>(_ list: ListType) async {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { await loadCurrencyList() }
        else if MainRepository.self == A.self { await loadAccountList() }
        else if MainRepository.self == E.self { await loadAssetList() }
        else if MainRepository.self == S.self { await loadStockList() }
        else if MainRepository.self == C.self { await loadCategoryList() }
        else if MainRepository.self == P.self { await loadPayeeList() }
    }

    func unloadList<ListType: ListProtocol>(_ list: ListType) {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { unloadCurrencyList() }
        else if MainRepository.self == A.self { unloadAccountList() }
        else if MainRepository.self == E.self { unloadAssetList() }
        else if MainRepository.self == S.self { unloadStockList() }
        else if MainRepository.self == C.self { unloadCategoryList() }
        else if MainRepository.self == P.self { unloadPayeeList() }
    }

    func loadList() async {
        await loadManageList()
        await loadCurrencyList()
        await loadAccountList()
        await loadAssetList()
        await loadStockList()
        await loadCategoryList()
        await loadPayeeList()
    }

    func unloadList() {
        unloadManegeList()
        unloadCurrencyList()
        unloadAccountList()
        unloadAssetList()
        unloadStockList()
        unloadCategoryList()
        unloadPayeeList()
    }
}
