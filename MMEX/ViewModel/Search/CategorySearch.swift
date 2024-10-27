//
//  CategorySaerch.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

struct CategorySearch: SearchProtocol {
    var area: [SearchArea<CategoryData>] = [
        ("Name", true,  [ {$0.name} ]),
        //("Path", false, [ {$0.path} ]),
    ]
    var key: String = ""
}
