//
//  CurrencySearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

struct CurrencySearch: SearchProtocol {
    var area: [SearchArea<CurrencyData>] = [
        ("Name",            true,  [ {$0.name} ], []),
        ("Symbol",          false, [ {$0.symbol} ], []),
        ("Decimal point",   false, [ {$0.decimalPoint} ], []),
        ("Group separator", false, [ {$0.groupSeparator} ], []),
        ("Other",           false, [ {$0.unitName}, {$0.centName} ], []),
    ]
    var key: String = ""
}
