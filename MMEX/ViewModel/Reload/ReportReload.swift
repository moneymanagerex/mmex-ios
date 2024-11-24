//
//  ReportReload.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadReport(_ pref: Preference, _ oldData: ReportData?, _ newData: ReportData?) async {
        log.trace("DEBUG: ViewModel.reloadReport(main=\(Thread.isMainThread))")

        // save isExpanded
        let groupIsExpanded: [Bool]? = reportGroup.readyValue?.map { $0.isExpanded }
        let groupIndex: [String: Int] = Dictionary(
            uniqueKeysWithValues: reportGroup.groupGroup.enumerated().map { ($0.1, $0.0) }
        )

        reportGroup.unload()
        reportList.unloadNone()

        if (oldData != nil) != (newData != nil) {
            reportList.count.unload()
        }

        if reportList.data.state.unloading() {
            if let newData {
                reportList.data.value[newData.id] = newData
            } else if let oldData {
                reportList.data.value[oldData.id] = nil
            }
            reportList.data.state.loaded()
        }

        reportList.order.unload()

        await loadReportList(pref)
        loadReportGroup(choice: reportGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch reportGroup.choice {
        case .group:
            for (g, group) in reportGroup.groupGroup.enumerated() {
                guard let i = groupIndex[group] else { continue }
                reportGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if reportGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    reportGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadReport(main=\(Thread.isMainThread))")
    }
}
