//
//  ReportValidation.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func copyReport(_ data: inout ReportData) {
        data.name.append(" (Copy)")
    }

    func updateReport(_ data: inout ReportData) -> String? {
        if data.name.isEmpty {
            return "Name is empty"
        }

        guard let r = R(self) else {
            return "* Database is not available"
        }

        guard let dataName = r.selectId(from: G.table.filter(
            R.table[R.col_id] == Int64(data.id) ||
            R.table[R.col_name] == data.name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (data.id.isVoid ? 0 : 1) else {
            return "Report \(data.name) already exists"
        }

        if data.id.isVoid {
            guard r.insert(&data) else {
                return "* Cannot create new report"
            }
        } else {
            guard r.update(data) else {
                return "* Cannot update report #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteReport(_ data: ReportData) -> String? {
        guard let reportUsed = reportList.used.readyValue else {
            return "* reportUsed is not loaded"
        }
        if reportUsed.contains(data.id) {
            return "* Report #\(data.id.value) is used"
        }

        guard let r = R(self) else {
            return "* Database is not available"
        }

        guard r.delete(data) else {
            return "* Cannot delete report #\(data.id.value)"
        }

        return nil
    }
}
