//
//  PayeeSearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct PayeeSearch: SearchProtocol {
    var area: [SearchArea<PayeeData>] = [
        ("Name",  true,  [ {$0.name} ], []),
        ("Notes", false, [ {$0.notes} ], []),
        ("Other", false, [ {$0.number}, {$0.website}, {$0.pattern} ], []),
    ]
    var key: String = ""
}

extension ViewModel {
    func payeeGroupIsVisible(_ g: Int, search: PayeeSearch
    ) -> Bool? {
        guard
            let listData  = payeeList.data.readyValue,
            let groupData = payeeGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch payeeGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchPayeeGroup(search: PayeeSearch, expand: Bool = false ) {
        guard payeeGroup.state == .ready else { return }
        for g in 0 ..< payeeGroup.value.count {
            guard let isVisible = payeeGroupIsVisible(g, search: search) else { return }
            payeeGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                payeeGroup.value[g].isExpanded = true
            }
        }
    }
}
