//
//  SearchProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

typealias SearchArea<MainData: DataProtocol> = (
    name: String,
    isSelected: Bool,
    mainValues: [(MainData) -> String],
    auxValues: [(ViewModel, MainData) -> String]
)

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

extension ViewModel {
    func searchGroup<GroupType: GroupProtocol, SearchType: SearchProtocol>(
        _ group: GroupType,
        search: SearchType,
        expand: Bool = false
    ) where GroupType.MainRepository.RepositoryData == SearchType.MainData {
        if GroupType.MainRepository.self == U.self {
            searchCurrencyGroup(search: search as! CurrencySearch)
        } else if GroupType.MainRepository.self == A.self {
            searchAccountGroup(search: search as! AccountSearch, expand: expand)
        } else if GroupType.MainRepository.self == E.self {
            searchAssetGroup(search: search as! AssetSearch, expand: expand)
        } else if GroupType.MainRepository.self == S.self {
            searchStockGroup(search: search as! StockSearch, expand: expand)
        } else if GroupType.MainRepository.self == C.self {
            searchCategoryGroup(search: search as! CategorySearch, expand: expand)
        } else if GroupType.MainRepository.self == P.self {
            searchPayeeGroup(search: search as! PayeeSearch, expand: expand)
        }
    }
}
