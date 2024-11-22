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
    mainValues: ((MainData) -> [String])?,
    auxValues: (@MainActor (ViewModel, MainData) -> [String])?
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

    @MainActor
    func match(_ vm: ViewModel, _ data: MainData) -> Bool {
        if key.isEmpty { return true }
        for i in 0 ..< area.count {
            guard area[i].isSelected else { continue }
            if let mainValues = area[i].mainValues {
                for value in mainValues(data) {
                    if value.localizedCaseInsensitiveContains(key) {
                        return true
                    }
                }
            }
            if let auxValues = area[i].auxValues {
                for value in auxValues(vm, data) {
                    if value.localizedCaseInsensitiveContains(key) {
                        return true
                    }
                }
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
        /**/   if GroupType.MainRepository.self == U.self {
            searchCurrencyGroup(search: search as! CurrencySearch)
        } else if GroupType.MainRepository.self == A.self {
            searchAccountGroup(search: search as! AccountSearch, expand: expand)
        } else if GroupType.MainRepository.self == E.self {
            searchAssetGroup(search: search as! AssetSearch, expand: expand)
        } else if GroupType.MainRepository.self == S.self {
            searchStockGroup(search: search as! StockSearch, expand: expand)
        } else if GroupType.MainRepository.self == C.self {
            searchCategory(search: search as! CategorySearch)
        } else if GroupType.MainRepository.self == P.self {
            searchPayeeGroup(search: search as! PayeeSearch, expand: expand)
        } else if GroupType.MainRepository.self == G.self {
            searchTagGroup(search: search as! TagSearch, expand: expand)
        } else if GroupType.MainRepository.self == F.self {
            searchFieldGroup(search: search as! FieldSearch, expand: expand)
        } else if GroupType.MainRepository.self == D.self {
            searchAttachmentGroup(search: search as! AttachmentSearch, expand: expand)
        } else if GroupType.MainRepository.self == BP.self {
            searchBudgetPeriodGroup(search: search as! BudgetPeriodSearch, expand: expand)
        } else if GroupType.MainRepository.self == B.self {
            searchBudgetGroup(search: search as! BudgetSearch, expand: expand)
        }
    }
}
