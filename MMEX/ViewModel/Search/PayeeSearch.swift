//
//  PayeeSearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

struct PayeeSearch: SearchProtocol {
    var area: [SearchArea<PayeeData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}
