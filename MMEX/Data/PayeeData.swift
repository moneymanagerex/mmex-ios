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

    mutating func resolveConstraint(conflictingWith existing: PayeeData? = nil) -> Bool {
        /// TODO column level
        self.name = "\(self.name):\(self.id)"
        return true
    }
}

extension PayeeData {
    static let sampleData: [PayeeData] = [
        PayeeData(
            id: 1, name: "Acme Payroll", categoryId: 2, number: "PAY-2048",
            website: "acmecorp.example", notes: "Primary salary"
        ),
        PayeeData(
            id: 2, name: "Green Market", categoryId: 8, number: "FOOD-118",
            website: "greenmarket.example", notes: "Weekly groceries"
        ),
        PayeeData(
            id: 3, name: "City Power", categoryId: 5, number: "UTIL-552",
            website: "citypower.example", notes: "Monthly electricity bill"
        ),
        PayeeData(
            id: 4, name: "CloudNet Internet", categoryId: 6, number: "NET-330",
            website: "cloudnet.example", notes: "Home internet"
        ),
        PayeeData(
            id: 5, name: "Metro Transit", categoryId: 10, number: "TRN-405",
            website: "metrotransit.example", notes: "Commute and transit cards"
        ),
        PayeeData(
            id: 6, name: "Sunday Cafe", categoryId: 12, number: "DIN-207",
            website: "sundaycafe.example", notes: "Coffee and brunch"
        ),
        PayeeData(
            id: 7, name: "Northstar Brokerage", categoryId: 14, number: "INV-912",
            website: "northstarinvest.example", notes: "Investment purchases"
        ),
        PayeeData(
            id: 8, name: "Bluebird Studio", categoryId: 3, number: "FREE-771",
            website: "bluebirdstudio.example", notes: "Freelance income"
        ),
    ]

    static var sampleDataIds : [DataId] {
        sampleData.map { $0.id }
    }
}
