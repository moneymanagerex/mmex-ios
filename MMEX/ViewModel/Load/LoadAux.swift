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

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        AuxRepository(db)?.selectBy(property: mainId, from: self.auxTable)
    }
}

typealias LoadAuxTagLink<MainRepository: RepositoryProtocol>
= LoadAuxData<MainRepository, TagLinkRepository>

typealias LoadAuxFieldValue<MainRepository: RepositoryProtocol>
= LoadAuxData<MainRepository, FieldValueRepository>

typealias LoadAuxAttachment<MainRepository: RepositoryProtocol>
= LoadAuxData<MainRepository, AttachmentRepository>

extension LoadAuxData where AuxRepository == TagLinkRepository {
    typealias GL = TagLinkRepository

    init(order: [SQLite.Expressible] = [GL.col_tagId]) {
        let refType: RefType? =
        MainRepository.self == TransactionRepository.self      ? .transaction      :
        MainRepository.self == TransactionSplitRepository.self ? .transactionSplit :
        MainRepository.self == ScheduledRepository.self        ? .scheduled        :
        MainRepository.self == ScheduledSplitRepository.self   ? .scheduledSplit   :
        nil

        var table = GL.table
        if let refType { table = table.filter(GL.col_refType == refType.rawValue) }

        self.init(
            mainId: { DataId($0[GL.col_refId]) },
            auxTable: table.order(order)
        )
    }
}

extension LoadAuxData where AuxRepository == FieldValueRepository {
    typealias FV = FieldValueRepository

    init(order: [SQLite.Expressible] = [FV.col_fieldId]) {
        let refType: RefType? =
        MainRepository.self == TransactionRepository.self ? .transaction :
        MainRepository.self == ScheduledRepository.self   ? .scheduled   :
        nil

        var table = FV.table
        if refType == .transaction {
            table = table.filter(FV.col_refId > 0)
        } else if refType == .scheduled {
            table = table.filter(FV.col_refId < 0)
        }

        self.init(
            mainId: refType == .scheduled
            ? { DataId(-$0[FV.col_refId]) }
            : { DataId($0[FV.col_refId]) },
            auxTable: table.order(order)
        )
    }
}

extension LoadAuxData where AuxRepository == AttachmentRepository {
    typealias D = AttachmentRepository

    init(order: [SQLite.Expressible] = [D.col_id]) {
        let refType: RefType? =
        MainRepository.self == AccountRepository.self     ? .account     :
        MainRepository.self == AssetRepository.self       ? .asset       :
        MainRepository.self == StockRepository.self       ? .stock       :
        MainRepository.self == PayeeRepository.self       ? .payee       :
        MainRepository.self == TransactionRepository.self ? .transaction :
        MainRepository.self == ScheduledRepository.self   ? .scheduled   :
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

    nonisolated func fetchValue(_ pref: Preference, _ db: SQLite.Connection?) async -> ValueType? {
        AuxRepository(db)?.selectBy(property: mainId, from: self.auxTable, with: auxValue)
    }
}
