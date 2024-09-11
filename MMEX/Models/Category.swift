//
//  Category.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct Category: Identifiable {
    var id: Int64
    var name: String
    var active: Bool
    var parentId: Int64?
}

extension Category {
    static let sampleData : [Category] =
    [
        Category(id: 1, name: "root cateogry", active: true, parentId: nil),
        Category(id: 2, name: "non-root category", active: true, parentId: 1)
    ]
}

extension Category {
    //
    static var empty : Category {Category(id: 1, name: "cateogry name", active: true, parentId: nil)}

    //
    static let table = Table("CATEGORY_V1")
    static let categID = Expression<Int64>("CATEGID")
    static let categName = Expression<String>("CATEGNAME")
    static let activeExpr = Expression<Int>("ACTIVE")
    static let parentID = Expression<Int64?>("PARENTID")
}
