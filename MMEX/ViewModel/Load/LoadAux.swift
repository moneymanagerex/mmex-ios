//
//  LoadAux.swift
//  MMEX
//
//  2024-10-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct LoadAuxData<
    MainRepository: RepositoryProtocol, AuxRepository: RepositoryProtocol
>: LoadFetchProtocol {
    typealias AuxData = AuxRepository.RepositoryData
    typealias ValueType = [DataId: [AuxData]]
    let loadName: String = "AuxData(\(MainRepository.repositoryName), \(AuxRepository.repositoryName))"
    let idleValue: ValueType = [:]

    let mainId: (SQLite.Row) -> DataId
    let auxTable: SQLite.Table
    var state: LoadState = .init()
    var value: ValueType

    init(mainId: @escaping (SQLite.Row) -> DataId, auxTable: SQLite.Table = AuxRepository.table) {
        self.mainId = mainId
        self.auxTable = auxTable
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ vm: ViewModel) async -> ValueType? {
        await AuxRepository(vm)?.selectBy(property: mainId, from: self.auxTable)
    }
}

typealias LoadAuxAtt<MainRepository: RepositoryProtocol>
= LoadAuxData<MainRepository, AttachmentRepository>

extension LoadAuxAtt {
    typealias D = AttachmentRepository

    init(order: [SQLite.Expressible] = [D.col_id]) {
        let refType: RefType? =
        MainRepository.self == AccountRepository.self     ? RefType.account     :
        MainRepository.self == AssetRepository.self       ? RefType.asset       :
        MainRepository.self == StockRepository.self       ? RefType.stock       :
        MainRepository.self == PayeeRepository.self       ? RefType.payee       :
        MainRepository.self == TransactionRepository.self ? RefType.transaction :
        MainRepository.self == ScheduledRepository.self   ? RefType.scheduled   :
        nil

        var table = D.table
        if let refType { table = table.filter(D.col_refType == refType.rawValue) }
        
        self.init(
            mainId: { DataId($0[D.col_refId]) },
            auxTable: table.order(order)
        )
    }
}

struct LoadAuxValue<
    MainRepository: RepositoryProtocol, AuxRepository: RepositoryProtocol, AuxValue
>: LoadFetchProtocol {
    typealias AuxData = AuxRepository.RepositoryData
    typealias ValueType = [DataId: [AuxValue]]
    let loadName: String = "AuxValue(\(MainRepository.repositoryName), \(AuxRepository.repositoryName))"
    let idleValue: ValueType = [:]

    let mainId: (SQLite.Row) -> DataId
    let auxTable: SQLite.Table
    let auxValue: (SQLite.Row) -> AuxValue
    var state: LoadState = .init()
    var value: ValueType

    init(
        mainId: @escaping (SQLite.Row) -> DataId,
        auxTable: SQLite.Table = AuxRepository.table,
        auxValue: @escaping (SQLite.Row) -> AuxValue
    ) {
        self.mainId = mainId
        self.auxTable = auxTable
        self.auxValue = auxValue
        self.value = idleValue
    }

    nonisolated func fetchValue(_ pref: Preference, _ vm: ViewModel) async -> ValueType? {
        await AuxRepository(vm)?.selectBy(property: mainId, from: self.auxTable, with: auxValue)
    }
}
