//
//  JournalSplitData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/23.
//

struct JournalSplitData: Identifiable, Codable {
    var id: DataId = .void
    var categId: DataId = .void
    var amount: Double = 0.0
    var notes: String = ""

    // var parentId: DataId = .void
}
