//
//  GroupProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol GroupChoiceProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
    static var isSingleton: Set<Self> { get }
    var fullName: String { get }
}

extension GroupChoiceProtocol {
    var fullName: String { self.rawValue }
}

struct GroupData {
    var name       : String?
    var dataId     : [DataId]
    var isVisible  : Bool
    var isExpanded : Bool
}

protocol GroupProtocol: LoadProtocol where ValueType == [GroupData] {
    associatedtype MainRepository: RepositoryProtocol
    associatedtype GroupChoice: GroupChoiceProtocol

    var choice: GroupChoice { get set }
}

extension GroupProtocol {
    var loadName: String { "Group(\(MainRepository.repositoryName))" }

    mutating func append(_ name: String?, _ dataId: [DataId], _ isVisible: Bool, _ isExpanded: Bool) {
        guard state == .loading else {
            log.error("ERROR: GroupProtocol.append(): state != loading.")
            return
        }
        value.append(GroupData(
            name: name, dataId: dataId, isVisible: isVisible, isExpanded: isExpanded
        ) )
    }
}

extension ViewModel {
    func loadGroup<GroupType: GroupProtocol>(
        _ group: GroupType,
        choice: GroupType.GroupChoice
    ) {
        typealias MainRepository = GroupType.MainRepository
        /**/ if MainRepository.self == U.self { loadCurrencyGroup(choice: choice as! CurrencyGroupChoice) }
        else if MainRepository.self == A.self { loadAccountGroup(choice: choice as! AccountGroupChoice) }
        else if MainRepository.self == E.self { loadAssetGroup(choice: choice as! AssetGroupChoice) }
        else if MainRepository.self == S.self { loadStockGroup(choice: choice as! StockGroupChoice) }
        else if MainRepository.self == C.self { loadCategoryGroup(choice: choice as! CategoryGroupChoice) }
        else if MainRepository.self == P.self { loadPayeeGroup(choice: choice as! PayeeGroupChoice) }
    }

    func unloadGroup<GroupType: GroupProtocol>(_ group: GroupType) {
        typealias MainRepository = GroupType.MainRepository
        /**/ if MainRepository.self == U.self { unloadCurrencyGroup() }
        else if MainRepository.self == A.self { unloadAccountGroup() }
        else if MainRepository.self == E.self { unloadAssetGroup() }
        else if MainRepository.self == S.self { unloadStockGroup() }
        else if MainRepository.self == C.self { unloadCategoryGroup() }
        else if MainRepository.self == P.self { unloadPayeeGroup() }
    }

    func unloadGroup() {
        unloadCurrencyGroup()
        unloadAccountGroup()
        unloadAssetGroup()
        unloadStockGroup()
        unloadCategoryGroup()
        unloadPayeeGroup()
    }

    func unloadAll() {
        unloadGroup()
        unloadList()
    }
}
