//
//  StockSaerch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockSearch: SearchProtocol {
    var area: [SearchArea<StockData>] = [
        ("Name",       true,  {[ $0.name ]}, nil),
        ("Symbol",     false, {[ $0.symbol ]}, nil),
        ("Account",    false, nil, { vm, data in [
            vm.accountList.data.readyValue?[data.accountId]?.name ?? ""
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
    func stockGroupIsVisible(_ g: Int, search: StockSearch
    ) -> Bool? {
        guard
            let listData  = stockList.data.readyValue,
            let groupData = stockGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch stockGroup.choice {
            case .account: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchStockGroup(search: StockSearch, expand: Bool = false ) {
        guard stockGroup.state == .ready else { return }
        for g in 0 ..< stockGroup.value.count {
            guard let isVisible = stockGroupIsVisible(g, search: search) else { return }
            stockGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                stockGroup.value[g].isExpanded = true
            }
        }
    }
}
