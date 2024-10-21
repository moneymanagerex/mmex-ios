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
    var shortName: String { get }
}

extension RepositoryGroupChoiceProtocol {
    var shortName: String { self.rawValue }
}

typealias RepositoryGroupData = (name: String?, dataId: [DataId])

protocol RepositoryLoadGroupProtocol {
    associatedtype GroupChoice : RepositoryGroupChoiceProtocol
    associatedtype MainRepository  : RepositoryProtocol

    var choice: GroupChoice { get set }
    var state: RepositoryLoadState<[RepositoryGroupData]> { get set }
    // problem: xListView cannot refresh if `isExpanded` is inside an enum
    // fix: store the following outside of `state`
    var isVisible  : [Bool] { get set }
    var isExpanded : [Bool] { get set }
}

enum RepositoryGroup {
    typealias AsTuple = (groupData: [RepositoryGroupData], isVisible: [Bool], isExpanded: [Bool])

    static func append(
        into groupTuple: inout AsTuple,
        _ name: String?,
        _ dataId: [DataId],
        _ isVisible: Bool,
        _ isExpanded: Bool
    ) {
        groupTuple.groupData.append((name, dataId))
        groupTuple.isVisible.append(isVisible)
        groupTuple.isExpanded.append(isExpanded)
    }
}
