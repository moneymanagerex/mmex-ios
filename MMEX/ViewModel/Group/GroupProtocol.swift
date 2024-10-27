//
//  GroupProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol GroupProtocol: LoadProtocol where ValueType == [GroupData] {
    associatedtype MainRepository: RepositoryProtocol
    associatedtype GroupChoice: GroupChoiceProtocol

    var choice: GroupChoice { get set }
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
