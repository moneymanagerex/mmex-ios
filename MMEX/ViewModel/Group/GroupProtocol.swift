//
//  GroupProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol GroupProtocol: Copyable {
    associatedtype MainRepository: RepositoryProtocol
    associatedtype GroupChoice: GroupChoiceProtocol

    var choice: GroupChoice { get set }
    var state: LoadState { get set }
    var value: [GroupData] { get set }

    mutating func unload()
}

extension GroupProtocol {
    mutating func append(_ name: String?, _ dataId: [DataId], _ isVisible: Bool, _ isExpanded: Bool) {
        guard state == .loading else {
            log.error("ERROR: GroupProtocol.append(): state != loading.")
            return
        }
        value.append(GroupData(
            name: name, dataId: dataId, isVisible: isVisible, isExpanded: isExpanded
        ) )
    }
}

extension GroupProtocol {
    mutating func unload() {
        guard state.unloading() else { return }
        log.trace("DEBUG: GroupProtocol.unload(\(MainRepository.repositoryName), main=\(Thread.isMainThread))")
        value = []
        state.unloaded()
    }
}
