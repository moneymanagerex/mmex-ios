//
//  AssetSearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

struct AssetSearch: SearchProtocol {
    var area: [SearchArea<AssetData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}
