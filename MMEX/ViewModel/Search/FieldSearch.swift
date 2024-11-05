//
//  FieldSaerch.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct FieldSearch: SearchProtocol {
    var area: [SearchArea<FieldData>] = [
        ("Description", true,  {[ $0.description ]}, nil),
        ("Properties",  false, {[ $0.properties ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func fieldGroupIsVisible(_ g: Int, search: FieldSearch
    ) -> Bool? {
        guard
            let listData  = fieldList.data.readyValue,
            let groupData = fieldGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch fieldGroup.choice {
            case .refType, .type: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchFieldGroup(search: FieldSearch, expand: Bool = false ) {
        guard fieldGroup.state == .ready else { return }
        for g in 0 ..< fieldGroup.value.count {
            guard let isVisible = fieldGroupIsVisible(g, search: search) else { return }
            fieldGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                fieldGroup.value[g].isExpanded = true
            }
        }
    }
}
