//
//  RepositoryGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol RepositoryGroupChoiceProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
    static var isSingleton: Set<Self> { get }
    var fullName: String { get }
}

extension RepositoryGroupChoiceProtocol {
    var fullName: String { self.rawValue }
}

struct RepositoryGroupData {
    var name       : String?
    var dataId     : [DataId]
    var isVisible  : Bool
    var isExpanded : Bool
}

protocol RepositoryGroupProtocol: Copyable {
    associatedtype MainRepository: RepositoryProtocol
    associatedtype GroupChoice: RepositoryGroupChoiceProtocol
    typealias ValueType = [RepositoryGroupData]

    var choice: GroupChoice { get set }
    var state: RepositoryLoadState { get set }
    var value: ValueType { get set }

    mutating func unload()
}

extension RepositoryGroupProtocol {
    mutating func append(_ name: String?, _ dataId: [DataId], _ isVisible: Bool, _ isExpanded: Bool) {
        guard state == .loading else {
            log.error("ERROR: RepositoryGroupProtocol.append(): state != loading.")
            return
        }
        value.append(RepositoryGroupData(
            name: name, dataId: dataId, isVisible: isVisible, isExpanded: isExpanded
        ) )
    }
}

extension RepositoryGroupProtocol {
    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: RepositoryGroupProtocol.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = []
        state.unloaded()
    }
}
