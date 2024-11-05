//
//  AttachmentSaerch.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AttachmentSearch: SearchProtocol {
    var area: [SearchArea<AttachmentData>] = [
        ("Filename",    true,  {[ $0.filename ]}, nil),
        ("Description", false, {[ $0.description ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func attachmentGroupIsVisible(_ g: Int, search: AttachmentSearch
    ) -> Bool? {
        guard
            let listData  = attachmentList.data.readyValue,
            let groupData = attachmentGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch attachmentGroup.choice {
            case .refType: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchAttachmentGroup(search: AttachmentSearch, expand: Bool = false ) {
        guard attachmentGroup.state == .ready else { return }
        for g in 0 ..< attachmentGroup.value.count {
            guard let isVisible = attachmentGroupIsVisible(g, search: search) else { return }
            attachmentGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                attachmentGroup.value[g].isExpanded = true
            }
        }
    }
}
