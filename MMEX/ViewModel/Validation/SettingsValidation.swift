//
//  SettingsValidation.swift
//  MMEX
//
//  2024-11-10: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateSettings(baseCurrencyId currencyId: DataId) -> String? {
        if !currencyId.isVoid {
            guard let currencyName = currencyList.name.readyValue else {
                return "* currencyName is not loaded"
            }
            if currencyName[currencyId] == nil {
                return "* Unknown currency #\(currencyId.value)"
            }
        }

        guard let i = I(self) else {
            return "* Database is not available"
        }

        guard i.setValue(currencyId, for: InfoKey.baseCurrencyID.rawValue) else {
            return "* Cannot set base currency to #\(currencyId.value)"
        }

        return nil
    }

    func updateSettings(defaultAccountId accountId: DataId) -> String? {
        if !accountId.isVoid {
            guard let accountData = accountList.data.readyValue else {
                return "* accountData is not loaded"
            }
            if accountData[accountId] == nil {
                return "* Unknown account #\(accountId.value)"
            }
        }

        guard let i = I(self) else {
            return "* Database is not available"
        }

        guard i.setValue(accountId, for: InfoKey.defaultAccountID.rawValue) else {
            return "* Cannot set default account to #\(accountId.value)"
        }

        return nil
    }

    func updateSettings(categoryDelimiter: String) -> String? {
        if categoryDelimiter.isEmpty {
            return "Delimiter is empty"
        }

        guard let i = I(self) else {
            return "* Database is not available"
        }

        guard i.setValue(categoryDelimiter, for: InfoKey.categDelimiter.rawValue) else {
            return "* Cannot set category delimiter to \"\(categoryDelimiter)\""
        }

        return nil
    }
}
