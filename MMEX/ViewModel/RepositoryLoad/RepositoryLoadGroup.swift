//
//  RepositoryLoadGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol RepositoryGroupChoiceProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
    static var isSingleton: Set<Self> { get }
}

struct RepositoryGroup {
    var dataId     : [[DataId]] = []
    var isVisible  : [Bool]     = []
    var isExpanded : [Bool]     = []
}

extension RepositoryGroup {
    static func append(
        into group: inout RepositoryGroup,
        _ dataId: [DataId],
        _ isVisible: Bool,
        _ isExpanded: Bool
    ) {
        group.dataId.append(dataId)
        group.isVisible.append(isVisible)
        group.isExpanded.append(isExpanded)
    }
}

protocol RepositoryLoadGroupProtocol {
    associatedtype GroupChoice: RepositoryGroupChoiceProtocol

    var choice: GroupChoice { get set }
    var state: RepositoryLoadState<RepositoryGroup> { get set }
}
