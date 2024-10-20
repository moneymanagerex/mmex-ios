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

protocol RepositoryLoadGroupProtocol {
    associatedtype GroupChoiceType : RepositoryGroupChoiceProtocol
    associatedtype RepositoryType  : RepositoryProtocol

    var choice: GroupChoiceType { get set }
    var state: RepositoryLoadState<[[DataId]]> { get set }
    var isVisible  : [Bool] { get set }
    var isExpanded : [Bool] { get set }
}

enum RepositoryGroup {
    typealias AsTuple = (dataId: [[DataId]], isVisible: [Bool], isExpanded: [Bool])

    static func append(
        into group: inout AsTuple,
        _ dataId: [DataId],
        _ isVisible: Bool,
        _ isExpanded: Bool
    ) {
        group.dataId.append(dataId)
        group.isVisible.append(isVisible)
        group.isExpanded.append(isExpanded)
    }
}
