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

struct RepositoryLoadGroup<GroupChoice: RepositoryGroupChoiceProtocol> {
    typealias DataType = RepositoryGroup
    
    var choice: GroupChoice = GroupChoice.defaultValue
    var state: RepositoryLoadState<DataType> = .init()

    init(choice: GroupChoice = GroupChoice.defaultValue) {
        self.choice = choice
    }
}
