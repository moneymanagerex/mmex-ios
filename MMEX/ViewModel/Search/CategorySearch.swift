//
//  CategorySaerch.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CategorySearch: SearchProtocol {
    var area: [SearchArea<CategoryData>] = [
        ("Name", true,  {[ $0.name ]}, nil),
        ("Path", false, nil, { vm, data in [
            vm.categoryList.path.readyValue?.path[data.id] ?? ""
        ] } ),
    ]
    var key: String = ""
}

extension ViewModel {
    func categoryGroupIsVisible(_ g: Int, search: CategorySearch
    ) -> Bool? {
        guard
            let listData  = categoryList.data.readyValue,
            let groupData = categoryGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch categoryGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchCategoryGroup(search: CategorySearch, expand: Bool = false ) {
        guard categoryGroup.state == .ready else { return }
        for g in 0 ..< categoryGroup.value.count {
            guard let isVisible = categoryGroupIsVisible(g, search: search) else { return }
            categoryGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                categoryGroup.value[g].isExpanded = true
            }
        }
    }
}
