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
}

struct RepositoryGroup<GroupChoice: RepositoryGroupChoiceProtocol> {
    var choice     : GroupChoice = GroupChoice.defaultValue
    var dataId     : [[DataId]]  = []
    var isVisible  : [Bool]      = []
    var isExpanded : [Bool]      = []
}

typealias RepositoryLoadGroup<GroupChoice: RepositoryGroupChoiceProtocol> = RepositoryLoadState<GroupChoice>
