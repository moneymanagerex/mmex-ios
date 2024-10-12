//
//  RpositoryViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol RepositoryPartitionProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
}

struct RepositoryGroup {
    var dataId     : [DataId] = []
    var isVisible  : Bool = true
    var isExpanded : Bool = true
}

protocol RepositoryViewModelProtocol: ObservableObject {
    associatedtype RepositoryData      : DataProtocol
    associatedtype RepositoryPartition : RepositoryPartitionProtocol

    var env          : EnvironmentManager { get }
    var dataById     : [DataId: RepositoryData] { get }
    var dataIsReady  : Bool { get set }
    var group        : [RepositoryGroup] { get set }
    var groupIsReady : Bool { get set }
    var partition    : RepositoryPartition { get set }
    var search       : String { get set }

    static var newData: RepositoryData { get }

    init(env: EnvironmentManager)

    func loadData() async -> Bool
    func newPartition(_ partition: RepositoryPartition)
    func newSearch(_ search: String?)
    func visible(data: RepositoryData) -> Bool
    func visible(groupId: Int) -> Bool
}

extension RepositoryViewModelProtocol {
    func dataId(ofGroup g: Int) -> [DataId] {
        self.group[g].dataId
    }

    func isVisible(group g: Int) -> Bool {
        self.group[g].isVisible
    }

    func isExpanded(group g: Int) -> Bool {
        self.group[g].isExpanded
    }

    func visible(dataId: DataId) -> Bool {
        visible(data: self.dataById[dataId]!)
    }

    func visible(groupId: Int) -> Bool {
        return search.isEmpty || group[groupId].dataId.first(
            where: { visible(dataId: $0) }
        ) != nil
    }

    func newSearch(_ search: String? = nil) {
        log.trace("RepositoryViewModelProtocol.newSearch(\(search ?? self.search))")
        if let search { self.search = search }
        guard dataIsReady else { return }
        groupIsReady = false
        for g in 0..<group.count {
            let isVisible = visible(groupId: g)
            group[g].isVisible = isVisible
            //log.debug("newSearch: \(g) = \(isVisible)")
            if (search != nil || !self.search.isEmpty) && isVisible {
                group[g].isExpanded = true
            }
        }
        groupIsReady = true
    }
}
