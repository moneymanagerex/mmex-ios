//
//  SearchProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol SearchProtocol: Copyable {
    associatedtype MainData: DataProtocol
    var area: [SearchArea<MainData>] { get set }
    var key: String { get set }
}

extension SearchProtocol {
    var prompt: String {
        "Search in " + area.compactMap { $0.isSelected ? $0.name : nil }.joined(separator: ", ")
    }

    var isEmpty: Bool { key.isEmpty }

    func match(_ vm: ViewModel, _ data: MainData) -> Bool {
        if key.isEmpty { return true }
        for i in 0 ..< area.count {
            guard area[i].isSelected else { continue }
            if area[i].mainValues.first(
                where: { $0(data).localizedCaseInsensitiveContains(key) }
            ) != nil {
                return true
            }
            if area[i].auxValues.first(
                where: { $0(vm, data).localizedCaseInsensitiveContains(key) }
            ) != nil {
                return true
            }
        }
        return false
    }
}