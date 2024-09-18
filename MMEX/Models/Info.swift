//
//  Info.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import Foundation

struct Info: Identifiable, Codable {
    var id: Int64 // ID will be auto-incremented
    var name: String // Corresponds to INFONAME
    var value: String // Corresponds to INFOVALUE
    
    init(id: Int64 = 0, name: String, value: String) {
        self.id = id
        self.name = name
        self.value = value
    }
}
