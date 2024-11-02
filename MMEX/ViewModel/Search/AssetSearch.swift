//
//  AssetSearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AssetSearch: SearchProtocol {
    var area: [SearchArea<AssetData>] = [
        ("Name",       true,  {[ $0.name ]}, nil),
        ("Currency",   false, nil, { vm, data in [
            vm.currencyList.name.readyValue?[data.currencyId] ?? ""
        ] } ),
        ("Attachment", false, nil, { vm, data in
            (vm.accountList.att.readyValue?[data.id]?.map { $0.description } ?? []) +
            (vm.accountList.att.readyValue?[data.id]?.map { $0.filename } ?? [])
        } ),
        ("Notes",      false, {[ $0.notes ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func assetGroupIsVisible(_ g: Int, search: AssetSearch
    ) -> Bool? {
        guard
            let listData  = assetList.data.readyValue,
            let groupData = assetGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch assetGroup.choice {
            case .type, .currency: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchAssetGroup(search: AssetSearch, expand: Bool = false ) {
        guard assetGroup.state == .ready else { return }
        for g in 0 ..< assetGroup.value.count {
            guard let isVisible = assetGroupIsVisible(g, search: search) else { return }
            assetGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                assetGroup.value[g].isExpanded = true
            }
        }
    }
}
