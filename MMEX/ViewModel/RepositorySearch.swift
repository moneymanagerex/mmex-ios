//
//  RepositorySearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

typealias RepositorySearchArea<RepositoryData: DataProtocol> = (
    name: String,
    isSelected: Bool,
    values: [(RepositoryData) -> String]
)

protocol RepositorySearchProtocol: Copyable {
    associatedtype RepositoryData: DataProtocol
    var area: [RepositorySearchArea<RepositoryData>] { get set }
    var key: String { get set }
}

extension RepositorySearchProtocol {
    var prompt: String {
        "Search in " + area.compactMap { $0.isSelected ? $0.name : nil }.joined(separator: ", ")
    }

    var isEmpty: Bool { key.isEmpty }

    func match(_ data: RepositoryData) -> Bool {
        if key.isEmpty { return true }
        for i in 0 ..< area.count {
            guard area[i].isSelected else { continue }
            if area[i].values.first(
                where: { $0(data).localizedCaseInsensitiveContains(key) }
            ) != nil {
                return true
            }
        }
        return false
    }
}

/*
extension OldRepositoryViewModelProtocol {
    func preloaded(env: EnvironmentManager, group: GroupChoiceType) -> Self {
        Task {
            await loadData(env: env)
            loadGroup(env: env, group: group)
            searchGroup()
        }
        return self
    }
    func dataIsVisible(_ dataId: DataId) -> Bool {
        search.match(dataById[dataId]!)
    }
}
*/
