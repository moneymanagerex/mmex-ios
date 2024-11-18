//
//  CurrencySearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencySearch: SearchProtocol {
    var area: [SearchArea<CurrencyData>] = [
        ("Name",            true,  {[ $0.name ]}, nil),
        ("Symbol",          false, {[ $0.symbol ]}, nil),
        ("Decimal point",   false, {[ $0.decimalPoint ]}, nil),
        ("Group separator", false, {[ $0.groupSeparator ]}, nil),
        ("Other",           false, {[ $0.unitName, $0.centName ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func currencyGroupIsVisible(_ g: Int, search: CurrencySearch) -> Bool? {
        guard
            let listData  = currencyList.data.readyValue,
            let groupData = currencyGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch currencyGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchCurrencyGroup(search: CurrencySearch, expand: Bool = false) {
        if currencyGroup.search { return }
        guard currencyGroup.state == .ready else { return }
        log.trace("DEBUG: ViewModel.searchCurrencyGroup(\(search.key), main=\(Thread.isMainThread))")
        for g in 0 ..< currencyGroup.value.count {
            guard let isVisible = currencyGroupIsVisible(g, search: search) else { return }
            currencyGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                currencyGroup.value[g].isExpanded = true
            }
        }
        currencyGroup.search = true
    }
}
