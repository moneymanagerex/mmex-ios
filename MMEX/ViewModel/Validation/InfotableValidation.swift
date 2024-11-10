//
//  InfotableValidation.swift
//  MMEX
//
//  2024-11-10: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateInfotable(baseCurrencyId currencyId: DataId) -> String? {
        if !currencyId.isVoid {
            guard let currencyName = currencyList.name.readyValue else {
                return "* currencyName is not loaded"
            }
            if currencyName[currencyId] == nil {
                return "* Unknown currency #\(currencyId.value)"
            }
        }

        guard let i = I(env) else {
            return "* Database is not available"
        }

        guard i.setValue(currencyId, for: InfoKey.baseCurrencyID.rawValue) else {
            return "* Cannot set base currency to #\(currencyId.value)"
        }

        return nil
    }
}
