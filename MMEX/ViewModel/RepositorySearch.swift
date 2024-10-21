//
//  RepositorySearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

typealias RepositorySearchArea<MainData: DataProtocol> = (
    name: String,
    isSelected: Bool,
    values: [(MainData) -> String]
)

protocol RepositorySearchProtocol: Copyable {
    associatedtype MainData: DataProtocol
    var area: [RepositorySearchArea<MainData>] { get set }
    var key: String { get set }
}

extension RepositorySearchProtocol {
    var prompt: String {
        "Search in " + area.compactMap { $0.isSelected ? $0.name : nil }.joined(separator: ", ")
    }

    var isEmpty: Bool { key.isEmpty }

    func match(_ data: MainData) -> Bool {
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
