//
//  SettingsReload.swift
//  MMEX
//
//  2024-11-10: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadSettings(baseCurrencyId newCurrencyId: DataId) async {
        log.trace("DEBUG: ViewModel.reloadSettings(baseCurrencyId:, main=\(Thread.isMainThread))")
        let oldCurrencyId = infotableList.baseCurrencyId.value
        if newCurrencyId == oldCurrencyId { return }
        
        var currencyChanged = false
        if !oldCurrencyId.isVoid {
            currencyList.used.unload()
            currencyList.info.unload()
            currencyChanged = true
        } else if !newCurrencyId.isVoid {
            if let currencyUsed = currencyList.used.readyValue, !currencyUsed.contains(newCurrencyId) {
                if currencyList.used.state.unloading() {
                    currencyList.used.value.insert(newCurrencyId)
                    currencyList.used.state.loaded()
                    currencyChanged = true
                }
            }
            if let currencyInfo = currencyList.info.readyValue, currencyInfo[newCurrencyId] == nil {
                currencyList.info.unload()
                currencyChanged = true
            }
        }
        if currencyChanged {
            unloadCurrencyGroup()
            currencyList.unloadNone()
        }
        
        if infotableList.baseCurrencyId.state.unloading() {
            infotableList.baseCurrencyId.value = newCurrencyId
            infotableList.baseCurrencyId.state.loaded()
        }
        
        log.info("INFO: ViewModel.reloadSettings(baseCurrencyId:, main=\(Thread.isMainThread))")
    }
    
    func reloadSettings(defaultAccountId newAccountId: DataId) async {
        log.trace("DEBUG: ViewModel.reloadSettings(defaultAccountId:, main=\(Thread.isMainThread))")
        let oldAccountId = infotableList.defaultAccountId.value
        if newAccountId == oldAccountId { return }

        var accountChanged = false
        if !oldAccountId.isVoid {
            accountList.used.unload()
            accountChanged = true
        } else if !newAccountId.isVoid {
            if let accountUsed = accountList.used.readyValue, !accountUsed.contains(newAccountId) {
                if accountList.used.state.unloading() {
                    accountList.used.value.insert(newAccountId)
                    accountList.used.state.loaded()
                    accountChanged = true
                }
            }
        }
        if accountChanged {
            unloadAccountGroup()
            accountList.unloadNone()
        }

        if infotableList.defaultAccountId.state.unloading() {
            infotableList.defaultAccountId.value = newAccountId
            infotableList.defaultAccountId.state.loaded()
        }

        log.info("INFO: ViewModel.reloadSettings(defaultAccountId:, main=\(Thread.isMainThread))")
    }

    /*
    func reloadSettings(categoryDelimiter newDelimiter: String) async {
        log.trace("DEBUG: ViewModel.reloadSettings(categoryDelimiter:, main=\(Thread.isMainThread))")
        let oldDelimiter = infotableList.categoryDelimiter.value
        if newDelimiter == oldDelimiter { return }

        categoryList.path.unload()

        if infotableList.categoryDelimiter.state.unloading() {
            infotableList.categoryDelimiter.value = newDelimiter
            infotableList.categoryDelimiter.state.loaded()
        }

        log.info("INFO: ViewModel.reloadSettings(categoryDelimiter:, main=\(Thread.isMainThread))")
    }
     */
}
