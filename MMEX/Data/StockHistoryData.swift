//
//  StockHistory.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

enum UpdateType: Int, CaseIterable, Identifiable, Codable {
    case none = 0
    case online
    case manual

    static let names = [
        "None",
        "Online",
        "Manual"
    ]
    var id: Int { self.rawValue }
    var name: String { Self.names[self.rawValue] }
}

struct StockHistoryData: ExportableEntity {
    var id         : DataId      = .void
    var symbol     : String      = ""
    var date       : DateString  = DateString("")
    var price      : Double      = 0.0
    var updateType : UpdateType? = nil
}

extension StockHistoryData: DataProtocol {
    static let dataName = ("Stock History", "Stock History")

    func shortDesc() -> String {
        "\(self.symbol), \(self.date)"
    }
}

extension StockHistoryData {
    static let sampleData: [StockHistoryData] = [
    ]
}
