//
//  Tag.swift
//  MMEX
//
//  Created 2024-09-25 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct TagData: ExportableEntity {
    var id     : Int64  = 0
    var name   : String = ""
    var active : Bool   = false
}

extension TagData: DataProtocol {
    static let dataName = "Tag"

    func shortDesc() -> String {
        "\(self.name)"
    }
}

extension TagData {
    static let sampleData: [TagData] = [
    ]
}