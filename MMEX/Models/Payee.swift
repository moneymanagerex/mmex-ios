//
//  Payee.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import Foundation
import SQLite

struct PayeeData: ExportableEntity {
    var id         : Int64
    var name       : String
    var categoryId : Int64
    var number     : String
    var website    : String
    var notes      : String
    var active     : Bool
    var pattern    : String

    init(
        id         : Int64   = 0,
        name       : String  = "",
        categoryId : Int64   = 0,
        number     : String  = "",
        website    : String  = "",
        notes      : String  = "",
        active     : Bool    = false,
        pattern    : String  = ""

    ) {
        self.id         = id
        self.name       = name
        self.categoryId = categoryId
        self.number     = number
        self.website    = website
        self.notes      = notes
        self.active     = active
        self.pattern    = pattern

    }
}

extension PayeeData: DataProtocol {
    static let modelName = "Payee"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

struct PayeeFull: FullProtocol {
    var data: PayeeData
    var category: CategoryFull?
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
