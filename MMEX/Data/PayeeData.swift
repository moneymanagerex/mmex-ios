//
//  PayeeData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct PayeeData: DataProtocol {
    var id         : DataId  = .void
    var name       : String  = ""
    var categoryId : DataId  = .void
    var number     : String  = ""
    var website    : String  = ""
    var notes      : String  = ""
    var active     : Bool    = false
    var pattern    : String  = ""
    
    // unique(name)
}

extension PayeeData {
    static let dataName = ("Payee", "Payees")

    func shortDesc() -> String {
        "\(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }
}

extension PayeeData {
    static let sampleData: [PayeeData] = [
        PayeeData(
            id: 1, name: "Payee A", categoryId: 1, number: "123456",
            website: "www.payeeA.com", notes: "Frequent payee"
        ),
        PayeeData(
            id: 2, name: "Payee B", categoryId: 2, number: "654321",
            website: "www.payeeB.com", notes: "Rare payee", active: false
        ),
        PayeeData(
            id: 3, name: "Electricity Company", categoryId: 4, number: "7891011",
            website: "www.electricity.com", notes: "Monthly electricity bill"
        ),
        PayeeData(
            id: 4, name: "ISP", categoryId: 5, number: "12131415",
            website: "www.isp.com", notes: "Internet service provider"
        ),
    ]

    static var sampleDataIds : [DataId] {
        sampleData.map { $0.id }
    }
}
