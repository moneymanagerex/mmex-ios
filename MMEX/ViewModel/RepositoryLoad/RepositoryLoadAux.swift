//
//  RepositoryLoadAux.swift
//  MMEX
//
//  2024-10-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct RepositoryLoadAuxData<
    MainRepository: RepositoryProtocol,
    AuxRepository: RepositoryProtocol
>: RepositoryLoadProtocol {
    typealias AuxData = AuxRepository.RepositoryData
    typealias LoadType = [DataId: [AuxData]]

    let mainId: (SQLite.Row) -> DataId
    let auxTable: SQLite.Table
    var state: RepositoryLoadState<LoadType> = .init()

    init(mainId: @escaping (SQLite.Row) -> DataId, auxTable: SQLite.Table = AuxRepository.table) {
        self.mainId = mainId
        self.auxTable = auxTable
    }

    func load(env: EnvironmentManager) -> LoadType? {
        AuxRepository(env)?.selectBy(property: mainId, from: self.auxTable)
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
    MainData: DataProtocol,
    AuxRepository: RepositoryProtocol,
    ValueType
>: RepositoryLoadProtocol {
    typealias AuxData = AuxRepository.RepositoryData
    typealias LoadType = [DataId: [ValueType]]

    let mainId: (SQLite.Row) -> DataId
    let auxTable: SQLite.Table
    let auxFetch: (SQLite.Row) -> ValueType
    var state: RepositoryLoadState<LoadType> = .init()

    init(
        mainId: @escaping (SQLite.Row) -> DataId,
        auxTable: SQLite.Table = AuxRepository.table,
        auxFetch: @escaping (SQLite.Row) -> ValueType
    ) {
        self.mainId = mainId
        self.auxTable = auxTable
        self.auxFetch = auxFetch
    }

    func load(env: EnvironmentManager) -> LoadType? {
        AuxRepository(env)?.selectBy(property: mainId, from: self.auxTable, with: auxFetch)
    }
}
