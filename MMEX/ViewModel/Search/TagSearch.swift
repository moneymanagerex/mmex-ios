//
//  TagSaerch.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct TagSearch: SearchProtocol {
    var area: [SearchArea<TagData>] = [
        ("Name", true, {[ $0.name ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func tagGroupIsVisible(_ g: Int, search: TagSearch
    ) -> Bool? {
        guard
            let listData  = tagList.data.readyValue,
            let groupData = tagGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch tagGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchTagGroup(search: TagSearch, expand: Bool = false) {
        guard tagGroup.state == .ready else { return }
        for g in 0 ..< tagGroup.value.count {
            guard let isVisible = tagGroupIsVisible(g, search: search) else { return }
            tagGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                tagGroup.value[g].isExpanded = true
            }
        }
    }
}
