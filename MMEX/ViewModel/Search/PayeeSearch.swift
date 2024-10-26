//
//  PayeeSearch.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

struct PayeeSearch: SearchProtocol {
    var area: [SearchArea<PayeeData>] = [
        ("Name",  true,  [ {$0.name} ]),
        ("Notes", false, [ {$0.notes} ]),
        ("Other", false, [ {$0.number}, {$0.website}, {$0.pattern} ]),
    ]
    var key: String = ""
}
