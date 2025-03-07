//
//  ReportData.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct ReportData: DataProtocol {
    var id              : DataId = .void
    var name            : String = ""
    var groupName       : String = ""
    var active          : Bool   = false
    var sqlContent      : String = ""
    var luaContent      : String = ""
    var templateContent : String = ""
    var description     : String = ""

    // unique(name)
}

struct ReportResult {
    var columnNames: [String]
    var rows: [[String: String]]
}

extension ReportData {
    static let dataName = ("Report", "Reports")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }

    mutating func resolveConstraint(conflictingWith existing: ReportData? = nil) -> Bool {
        /// TODO column level
        self.name = "\(self.name):\(self.id)"
        return true
    }
}

extension ReportData {
    static let sampleData: [ReportData] = [
        ReportData(
            id: 1, name: "report 1", active: true
            , sqlContent: "SELECT STARTDATE, ASSETNAME, ASSETTYPE, VALUE, NOTES, VALUECHANGE, VALUECHANGERATE FROM ASSETS_V1"
        ),
        ReportData(
            id: 2, name: "report 2", active: true
            , sqlContent: "SELECT * FROM REPORT_V1"
        ),
    ]
}
