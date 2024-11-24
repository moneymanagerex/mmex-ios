//
//  ReportValidation.swift
//  MMEX
//
//  2024-11-22: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ReportData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if name.isEmpty {
            return "Name is empty"
        }

        typealias R = ViewModel.R
        guard let r = R(vm) else {
            return "* Database is not available"
        }

        guard let dataName = r.selectId(from: R.table.filter(
            R.table[R.col_id] == Int64(id) ||
            R.table[R.col_name] == name
        ) ) else {
            return "* Cannot fetch from database"
        }
        guard dataName.count == (id.isVoid ? 0 : 1) else {
            return "Report \(name) already exists"
        }

        if id.isVoid {
            guard r.insert(&self) else {
                return "* Cannot create new report"
            }
        } else {
            guard r.update(self) else {
                return "* Cannot update report #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let reportUsed = vm.reportList.used.readyValue else {
            return "* reportUsed is not loaded"
        }
        if reportUsed.contains(id) {
            return "* Report #\(id.value) is used"
        }

        typealias R = ViewModel.R
        guard let r = R(vm) else {
            return "* Database is not available"
        }

        guard r.delete(self) else {
            return "* Cannot delete report #\(id.value)"
        }

        return nil
    }
}
