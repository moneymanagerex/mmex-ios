//
//  StockSaerch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

struct StockSearch: SearchProtocol {
    var area: [SearchArea<StockData>] = [
        ("Name",   true,  [ {$0.name} ]),
        ("Symbol", false, [ {$0.symbol} ]),
        ("Notes",  false, [ {$0.notes} ]),
    ]
    var key: String = ""
}
