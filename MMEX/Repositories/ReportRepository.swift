//
//  ReportRepository.swift
//  MMEX
//
//  Created 2024-09-26 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

class ReportRepository: RepositoryProtocol {
    typealias RepositoryData = ReportData

    let db: Connection?
    init(db: Connection?) {
        self.db = db
    }

    static let repositoryName = "REPORT_V1"
    static let table = SQLite.Table(repositoryName)

    // column        | type    | other
    // --------------+---------+------
    // REPORTID        | INTEGER | PRIMARY KEY
    // REPORTNAME      | TEXT    | NOT NULL UNIQUE COLLATE NOCASE
    // GROUPNAME       | TEXT    | COLLATE NOCASE
    // ACTIVE          | INTEGER |
    // SQLCONTENT      | TEXT    |
    // LUACONTENT      | TEXT    |
    // TEMPLATECONTENT | TEXT    |
    // DESCRIPTION     | TEXT    |

    // column expressions
    static let col_id              = SQLite.Expression<Int64>("REPORTID")
    static let col_name            = SQLite.Expression<String>("REPORTNAME")
    static let col_groupName       = SQLite.Expression<String?>("GROUPNAME")
    static let col_active          = SQLite.Expression<Int?>("ACTIVE")
    static let col_sqlContent      = SQLite.Expression<String?>("SQLCONTENT")
    static let col_luaContent      = SQLite.Expression<String?>("LUACONTENT")
    static let col_templateContent = SQLite.Expression<String?>("TEMPLATECONTENT")
    static let col_description     = SQLite.Expression<String?>("DESCRIPTION")

    static func selectQuery(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_name,
            col_groupName,
            col_active,
            col_sqlContent,
            col_luaContent,
            col_templateContent,
            col_description
        )
    }

    static func selectData(_ row: SQLite.Row) -> ReportData {
        return ReportData(
            id              : row[col_id],
            name            : row[col_name],
            groupName       : row[col_groupName] ?? "",
            active          : row[col_active] ?? 0 != 0,
            sqlContent      : row[col_sqlContent] ?? "",
            luaContent      : row[col_luaContent] ?? "",
            templateContent : row[col_templateContent] ?? "",
            description     : row[col_description] ?? ""
        )
    }

    static func itemSetters(_ data: ReportData) -> [SQLite.Setter] {
        return [
            col_name            <- data.name,
            col_groupName       <- data.groupName,
            col_active          <- data.active ? 1 : 0,
            col_sqlContent      <- data.sqlContent,
            col_luaContent      <- data.luaContent,
            col_templateContent <- data.templateContent,
            col_description     <- data.description
        ]
    }
}

extension ReportRepository {
    // load all reports
    func load() -> [ReportData] {
        return select(from: Self.table
            .order(Self.col_name)
        )
    }
}
