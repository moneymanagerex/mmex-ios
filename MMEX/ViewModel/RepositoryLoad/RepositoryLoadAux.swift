//
//  RepositoryLoadAux.swift
//  MMEX
//
//  2024-10-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct RepositoryLoadAuxData<
    MainRepository: RepositoryProtocol, AuxRepository: RepositoryProtocol
>: RepositoryLoadProtocol {
    typealias AuxData = AuxRepository.RepositoryData
    typealias ValueType = [DataId: [AuxData]]

    let mainId: (SQLite.Row) -> DataId
    let auxTable: SQLite.Table
    var state: RepositoryLoadState = .init()
    var value: ValueType = [:]

    init(mainId: @escaping (SQLite.Row) -> DataId, auxTable: SQLite.Table = AuxRepository.table) {
        self.mainId = mainId
        self.auxTable = auxTable
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        AuxRepository(env)?.selectBy(property: mainId, from: self.auxTable)
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainAuxData.unload(\(MainRepository.repositoryName), \(AuxRepository.repositoryName), main=\(Thread.isMainThread))")
        value = [:]
        state.unloaded()
    }
}

typealias RepositoryLoadAuxAtt<MainRepository: RepositoryProtocol>
= RepositoryLoadAuxData<MainRepository, AttachmentRepository>

extension RepositoryLoadAuxAtt {
    typealias AX = AttachmentRepository

    init(order: [SQLite.Expressible] = [AX.col_id]) {
        let refType: RefType? =
        MainRepository.self == AccountRepository.self     ? RefType.account     :
        MainRepository.self == AssetRepository.self       ? RefType.asset       :
        MainRepository.self == StockRepository.self       ? RefType.stock       :
        MainRepository.self == PayeeRepository.self       ? RefType.payee       :
        MainRepository.self == TransactionRepository.self ? RefType.transaction :
        MainRepository.self == ScheduledRepository.self   ? RefType.scheduled   :
        nil

        var table = AX.table
        if let refType { table = table.filter(AX.col_refType == refType.rawValue) }
        
        self.mainId = { DataId($0[AX.col_refId]) }
        self.auxTable = table.order(order)
    }
}

struct RepositoryLoadAuxValue<
    MainRepository: RepositoryProtocol, AuxRepository: RepositoryProtocol, AuxValue
>: RepositoryLoadProtocol {
    typealias AuxData = AuxRepository.RepositoryData
    typealias ValueType = [DataId: [AuxValue]]

    let mainId: (SQLite.Row) -> DataId
    let auxTable: SQLite.Table
    let auxValue: (SQLite.Row) -> AuxValue
    var state: RepositoryLoadState = .init()
    var value: ValueType = [:]

    init(
        mainId: @escaping (SQLite.Row) -> DataId,
        auxTable: SQLite.Table = AuxRepository.table,
        auxValue: @escaping (SQLite.Row) -> AuxValue
    ) {
        self.mainId = mainId
        self.auxTable = auxTable
        self.auxValue = auxValue
    }

    func fetch(env: EnvironmentManager) -> ValueType? {
        AuxRepository(env)?.selectBy(property: mainId, from: self.auxTable, with: auxValue)
    }

    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryLoadMainAuxValue.unload(\(MainRepository.repositoryName), \(AuxRepository.repositoryName), main=\(Thread.isMainThread))")
        value = [:]
        state.unloaded()
    }
}
