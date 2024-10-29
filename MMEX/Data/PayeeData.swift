//
//  Payee.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct PayeeData: ExportableEntity {
    var id         : DataId  = .void
    var name       : String  = ""
    var categoryId : DataId  = .void
    var number     : String  = ""
    var website    : String  = ""
    var notes      : String  = ""
    var active     : Bool    = false
    var pattern    : String  = ""
}

extension PayeeData: DataProtocol {
    static let dataName = ("Payee", "Payees")

    func shortDesc() -> String {
        "\(self.name)"
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
    ]
}
