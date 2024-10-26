//
//  CurrencySearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

struct CurrencySearch: SearchProtocol {
    var area: [SearchArea<CurrencyData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}
