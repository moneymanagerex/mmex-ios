//
//  CategorySymbol.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/12/11.
//

import Foundation

struct Name2Symbol {
    @StoredPreferenceDictionary(key: "CategorySymbols") var category2symbol: [String: String]
}

extension Name2Symbol {
    init(prefix: String?) {
        /// TODO
        category2symbol.merge(CategoryData.categoryToSFSymbol) { current, _ in current }
    }
}
