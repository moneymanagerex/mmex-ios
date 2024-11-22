//
//  ReportSaerch.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct ReportSearch: SearchProtocol {
    var area: [SearchArea<ReportData>] = [
        ("Name",        true,  {[ $0.name ]}, nil),
        ("Group",       false, {[ $0.groupName ]}, nil),
        ("SQL",         false, {[ $0.sqlContent ]}, nil),
        ("Lua",         false, {[ $0.luaContent ]}, nil),
        ("Template",    false, {[ $0.templateContent ]}, nil),
        ("Description", false, {[ $0.description ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func reportGroupIsVisible(_ g: Int, search: ReportSearch) -> Bool? {
        guard
            let listData  = reportList.data.readyValue,
            let groupData = reportGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch reportGroup.choice {
            case .group: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchReportGroup(search: ReportSearch, expand: Bool = false) {
        if assetGroup.search { return }
        guard reportGroup.state == .ready else { return }
        log.trace("DEBUG: ViewModel.searchReportGroup(\(search.key), main=\(Thread.isMainThread))")
        for g in 0 ..< reportGroup.value.count {
            guard let isVisible = reportGroupIsVisible(g, search: search) else { return }
            reportGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                reportGroup.value[g].isExpanded = true
            }
        }
        assetGroup.search = true
    }
}
